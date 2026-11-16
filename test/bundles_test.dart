/// AuthorOS Write 3.0's bundles (0.23.0): three products that take older
/// products in.
///
/// Held here: what each bundle takes in; that taking in runs one way and one
/// level; that `owns` stays exact while `opens` follows a bundle; that an
/// owner of an old product keeps exactly what it opened; and that nothing an
/// existing account holds reads differently than it did.
library;

import 'package:authoros_core/entitlement.dart';
import 'package:test/test.dart';

Entitlements _holding(Iterable<PaidProduct> products) => Entitlements([
      for (final product in products)
        Entitlement(
          productId: product.id,
          grantedAt: DateTime.utc(2026, 11, 16),
        ),
    ]);

void main() {
  const bundles = [
    PaidProduct.aosWorldbuilding,
    PaidProduct.aosRevisePublish,
    PaidProduct.aosStudioPlus,
  ];

  group('the catalogue', () {
    test('the bundles have wire ids of their own, and none is reused', () {
      expect(PaidProduct.aosWorldbuilding.id, 'aos-worldbuilding');
      expect(PaidProduct.aosRevisePublish.id, 'aos-revise-publish');
      expect(PaidProduct.aosStudioPlus.id, 'aos-studio-plus');
      final ids = [for (final product in PaidProduct.values) product.id];
      expect(ids.toSet(), hasLength(ids.length));
      for (final product in PaidProduct.values) {
        expect(PaidProduct.byId(product.id), product);
      }
    });

    test('exactly the three are bundles, none retired, none a free claim',
        () {
      expect([
        for (final product in PaidProduct.values)
          if (product.isBundle) product,
      ], bundles);
      for (final bundle in bundles) {
        expect(bundle.isRetired, isFalse);
        expect(bundle.isFreeClaim, isFalse);
      }
    });

    test('only Studio Plus is a subscription', () {
      expect([
        for (final product in PaidProduct.values)
          if (product.isSubscription) product,
      ], [PaidProduct.aosStudioPlus]);
    });

    test('each bundle takes in what the owner settled', () {
      expect(PaidProduct.aosWorldbuilding.includes, {
        PaidProduct.aosCartographer,
        PaidProduct.aosCasebook,
        PaidProduct.aosLorekeeper,
        PaidProduct.aosCodexBibles,
        PaidProduct.calendarBible,
        PaidProduct.aosHeartsAndTensions,
      });
      expect(PaidProduct.aosRevisePublish.includes, {
        PaidProduct.aosUnblocked,
        PaidProduct.aosPress,
        PaidProduct.aosCoverStudio,
      });
      expect(PaidProduct.aosStudioPlus.includes, {PaidProduct.aosCommonRoom});
    });

    test('no bundle takes in a bundle, and no product is in two', () {
      for (final bundle in bundles) {
        expect(bundle.includes.where((part) => part.isBundle), isEmpty);
      }
      for (final product in PaidProduct.values) {
        expect(product.includedIn.length, lessThanOrEqualTo(1),
            reason: product.id);
      }
    });

    test('Companion, Worldsmith, the bookplate and Create are in no bundle',
        () {
      for (final product in const [
        PaidProduct.aosCompanion,
        PaidProduct.aosWorldsmith,
        PaidProduct.bookplateMaker,
        PaidProduct.aosCreate,
      ]) {
        expect(product.includedIn, isEmpty, reason: product.id);
      }
    });
  });

  group('what an account may use', () {
    test('a bundle opens each product it takes in', () {
      final held = _holding([PaidProduct.aosWorldbuilding]);
      for (final part in PaidProduct.aosWorldbuilding.includes) {
        expect(held.opens(part), isTrue, reason: part.id);
      }
      expect(held.opens(PaidProduct.aosWorldbuilding), isTrue);
      // And nothing of another bundle's.
      expect(held.opens(PaidProduct.aosPress), isFalse);
      expect(held.opens(PaidProduct.aosCommonRoom), isFalse);
      expect(held.opens(PaidProduct.aosCompanion), isFalse);
    });

    test('a part does not open its bundle, or the bundle\'s other parts', () {
      final held = _holding([PaidProduct.aosCasebook]);
      expect(held.opens(PaidProduct.aosCasebook), isTrue);
      expect(held.opens(PaidProduct.aosWorldbuilding), isFalse);
      expect(held.opens(PaidProduct.aosCartographer), isFalse);
      expect(held.opens(PaidProduct.aosLorekeeper), isFalse);
    });

    test('owns stays exact: a bundle is not its parts', () {
      final held = _holding([PaidProduct.aosRevisePublish]);
      expect(held.owns(PaidProduct.aosRevisePublish), isTrue);
      expect(held.owns(PaidProduct.aosPress), isFalse);
      expect(held.opens(PaidProduct.aosPress), isTrue);
    });

    test('an old licence opens what it always opened, bundle or no bundle',
        () {
      for (final product in PaidProduct.values) {
        expect(_holding([product]).opens(product), isTrue,
            reason: product.id);
      }
      // The retired bundle is still held, and still read.
      final create = _holding([PaidProduct.aosCreate]);
      expect(create.owns(PaidProduct.aosCreate), isTrue);
      expect(create.opens(PaidProduct.aosCreate), isTrue);
    });

    test('nobody opens anything by holding nothing', () {
      for (final product in PaidProduct.values) {
        expect(Entitlements.none.opens(product), isFalse);
      }
      expect(Entitlements.none.openedIds, isEmpty);
    });

    test('openedIds names what is held, what a bundle takes in, and an id '
        'this build does not know', () {
      final held = Entitlements([
        Entitlement(
            productId: 'aos-studio-plus', grantedAt: DateTime.utc(2026, 11)),
        Entitlement(
            productId: 'aos-casebook', grantedAt: DateTime.utc(2026, 11)),
        Entitlement(
            productId: 'aos-from-the-future', grantedAt: DateTime.utc(2026, 11)),
      ]);
      expect(held.openedIds, {
        'aos-studio-plus',
        'aos-common-room',
        'aos-casebook',
        'aos-from-the-future',
      });
    });

    test('an entitlement written before the bundles reads as it did', () {
      final stored = [
        {
          'productId': 'aos-press',
          'grantedAt': '2026-10-01T00:00:00.000Z',
          'source': 'purchase',
        },
      ];
      final held = Entitlements.fromJson(stored);
      expect(held.owns(PaidProduct.aosPress), isTrue);
      expect(held.opens(PaidProduct.aosPress), isTrue);
      expect(held.toJson(), stored);
    });
  });
}
