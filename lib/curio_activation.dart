/// Curios — which of the ones this account owns a project has switched on.
///
/// **Owning and enabling are different facts**, and keeping them apart is the
/// whole reason this exists. Ownership is account-scoped: it follows the author
/// to every machine, it arrives through sync, and nothing in this application
/// can grant or revoke it ([ADR-0005](../../../indiauthors-platform/docs/architecture/ADR-0005-hosting-topology.md)
/// §5). Enablement is project-scoped: a historical novel does not want a
/// heraldry generator on its sidebar, and the next book might.
///
/// Switching a Curio off is not giving it back. The entitlement is untouched,
/// the record below is the only thing that changes, and switching it back on
/// restores exactly what was there.
///
/// ## Why this is not `SpecialistActivation`
///
/// It is the same shape — one record per project, a set of ids in `fields` —
/// and putting product ids in that record was the first thing considered. It
/// was rejected because `test/specialist_architecture_test.dart` holds a
/// boundary that would have to be weakened to allow it: *"Activation may be
/// read by a specialist picker or view. Nothing else may read it, and no read
/// path may."* That guard exists so a preference cannot quietly filter a
/// repository, and a Curios surface reading that record would spend it.
///
/// So the **pattern** is copied and the **state** is not. Two vocabularies —
/// specialist system ids there, `PaidProduct` wire ids here — answering two
/// questions, in two records that cannot read each other by accident.
///
/// ## Why the state lives in `fields`
///
/// The same reason it does there. [RecordService.updateRecord] merges
/// `extensionData` and *replaces* `fields`, so a key removed from
/// `extensionData` comes back from what was already stored. Switching off the
/// last enabled Curio is an ordinary thing to do, and it must be able to reach
/// empty.
///
/// ## What this may and may not touch
///
/// Disabling a Curio means one thing: **do not offer its tool on this project.**
/// It never deletes, archives, mutates, migrates, unlinks or de-indexes
/// anything — a bookplate an author designed stays exactly where it was.
/// Nothing in this library reads or writes a record other than the single
/// activation record below.
library;

import 'connected_domain.dart';
import 'connected_domain_repository.dart';
import 'entitlement.dart';
import 'record_service.dart';

/// The record type carrying a project's Curio activation.
///
/// Infrastructure rather than author content, like `specialistSystemState` and
/// `codexCategory`: organisational metadata over ids, never graph truth. It
/// takes no links and no connection type accepts it as an endpoint.
const String kCurioActivationTypeId = 'curioActivation';

/// The field holding the enabled product ids. A `list`, so a project that has
/// enabled nothing holds an empty list rather than an absent key.
const String kEnabledCurioIdsFieldId = 'enabledCurioIds';

/// The activation record's id for [projectId].
///
/// Derived rather than minted, for the reason the specialist one gives: one
/// record per project makes the id a function of the project, so there is no
/// counter and no collision to design against, and the read is a primary-key
/// hit.
String curioActivationRecordId(String projectId) => 'curios:$projectId';

/// Which Curios one project has switched on.
class CurioActivation {
  const CurioActivation(this.enabledProductIds);

  /// A project that has switched nothing on — the state of every project until
  /// an author says otherwise, including one whose account owns everything.
  static const none = CurioActivation(<String>{});

  /// Wire ids, not [PaidProduct] values.
  ///
  /// An id this build cannot name is kept rather than dropped, the same rule
  /// `Entitlements.unknown` follows: an older build that discarded what it
  /// could not name would switch off a Curio a newer one had enabled, and the
  /// author would have to find the switch again.
  final Set<String> enabledProductIds;

  bool isEnabled(String productId) => enabledProductIds.contains(productId);

  bool isProductEnabled(PaidProduct product) => isEnabled(product.id);

  /// Ordered, so callers and tests agree on sequence.
  List<String> get sorted => enabledProductIds.toList()..sort();

  CurioActivation withEnabled(String productId) =>
      CurioActivation({...enabledProductIds, productId});

  CurioActivation withDisabled(String productId) => CurioActivation(
        {...enabledProductIds}..remove(productId),
      );

  @override
  bool operator ==(Object other) =>
      other is CurioActivation &&
      other.enabledProductIds.length == enabledProductIds.length &&
      other.enabledProductIds.containsAll(enabledProductIds);

  @override
  int get hashCode => Object.hashAllUnordered(enabledProductIds);

  @override
  String toString() => 'CurioActivation(${sorted.join(', ')})';
}

/// Reads and writes one project's Curio activation.
///
/// Every write goes through [RecordService], so switching a Curio on is
/// validated, versioned and audited exactly like an author editing a character.
class CurioActivationService {
  const CurioActivationService({
    required this.projectId,
    required this.repository,
  });

  final String projectId;
  final ConnectedDomainRepository repository;

  RecordService get records =>
      RecordService(projectId: projectId, repository: repository);

  String get recordId => curioActivationRecordId(projectId);

  /// This project's activation.
  ///
  /// A project with no activation record has switched nothing on, which is the
  /// correct answer rather than a missing one — so nothing is written just to
  /// read.
  Future<CurioActivation> load() async {
    final record = await records.getRecord(recordId);
    if (record == null) return CurioActivation.none;
    return CurioActivation(_idsFrom(record));
  }

  Future<bool> isEnabled(String productId) async =>
      (await load()).isEnabled(productId);

  Future<CurioActivation> enable(
    String productId, {
    DateTime? timestamp,
  }) async =>
      _write((await load()).withEnabled(productId), timestamp: timestamp);

  Future<CurioActivation> disable(
    String productId, {
    DateTime? timestamp,
  }) async =>
      _write((await load()).withDisabled(productId), timestamp: timestamp);

  /// Replaces the whole set. An empty set is a legitimate value and clears the
  /// field rather than leaving the previous ids behind.
  Future<CurioActivation> setEnabled(
    Iterable<String> productIds, {
    DateTime? timestamp,
  }) =>
      _write(CurioActivation(productIds.toSet()), timestamp: timestamp);

  Future<CurioActivation> _write(
    CurioActivation activation, {
    DateTime? timestamp,
  }) async {
    final now = (timestamp ?? DateTime.now()).toUtc();
    final existing = await records.getRecord(recordId);
    final fields = <String, Object?>{
      kEnabledCurioIdsFieldId: activation.sorted,
    };

    if (existing == null) {
      await records.createRecord(
        AuthorRecord(
          id: recordId,
          typeId: kCurioActivationTypeId,
          templateId: kCurioActivationTypeId,
          scopeType: RecordScopeType.project,
          scopeId: projectId,
          projectId: projectId,
          canonStatus: CanonStatus.canon,
          title: 'Curios',
          fields: fields,
          createdAt: now,
          updatedAt: now,
        ),
        summary: 'Set Curios for $projectId',
      );
      return activation;
    }

    await records.updateRecord(
      existing.copyWith(fields: fields, updatedAt: now),
      summary: 'Set Curios for $projectId',
    );
    return activation;
  }

  /// Reads the ids out of a record, tolerantly.
  ///
  /// A malformed or absent value reads as "nothing enabled" rather than
  /// throwing. Activation is a preference; a project must open even if this one
  /// record is unreadable, and the author's records are unaffected either way.
  static Set<String> _idsFrom(AuthorRecord record) {
    final raw = record.fields[kEnabledCurioIdsFieldId];
    if (raw is! List) return const {};
    return {
      for (final value in raw)
        if (value is String && value.trim().isNotEmpty) value.trim(),
    };
  }
}
