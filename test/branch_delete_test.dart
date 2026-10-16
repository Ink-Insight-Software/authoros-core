import 'package:authoros_core/branch_domain.dart';
import 'package:authoros_core/branch_service.dart';
import 'package:authoros_core/connected_domain_repository.dart';
import 'package:test/test.dart';

/// `BranchService.deleteBranch` decides what may be deleted; the store does
/// the deleting. The store's side is tested where a store is
/// (authoros_persistence).
void main() {
  final at = DateTime.utc(2026, 10, 16);
  StoryBranch branch(String id,
          {String projectId = 'world-a', String? parent}) =>
      StoryBranch(
        id: id,
        projectId: projectId,
        name: 'Branch $id',
        createdAt: at,
        kind: BranchKind.whatIf,
        parentBranchId: parent,
      );

  test('deletes a branch through the repository', () async {
    final repository = _Branches([branch('b1'), branch('b2')]);
    final service = BranchService(projectId: 'world-a', repository: repository);
    expect(await service.deleteBranch('b1'), 7);
    expect(repository.deleted, ['b1']);
  });

  test('refuses a branch another branch descends from', () async {
    final repository = _Branches([branch('b1'), branch('b2', parent: 'b1')]);
    final service = BranchService(projectId: 'world-a', repository: repository);
    await expectLater(
      service.deleteBranch('b1'),
      throwsA(isA<StateError>().having(
        (e) => e.message,
        'message',
        contains('Branch b2'),
      )),
    );
    expect(repository.deleted, isEmpty);
    // The child itself can go, and then the parent.
    await service.deleteBranch('b2');
    await service.deleteBranch('b1');
    expect(repository.deleted, ['b2', 'b1']);
  });

  test('refuses a branch that is not the project\'s', () async {
    final repository = _Branches([branch('b9', projectId: 'world-b')]);
    final service = BranchService(projectId: 'world-a', repository: repository);
    await expectLater(service.deleteBranch('b9'), throwsStateError);
    await expectLater(service.deleteBranch('missing'), throwsStateError);
    expect(repository.deleted, isEmpty);
  });
}

class _Branches implements ConnectedDomainRepository {
  _Branches(this.branches);

  final List<StoryBranch> branches;
  final deleted = <String>[];

  @override
  Future<List<StoryBranch>> branchesByProject(String projectId) async => [
        for (final branch in branches)
          if (branch.projectId == projectId) branch,
      ];

  @override
  Future<int> deleteBranch(String branchId) async {
    deleted.add(branchId);
    branches.removeWhere((branch) => branch.id == branchId);
    return 7;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
