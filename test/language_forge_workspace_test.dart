import 'package:authoros_core/language_forge.dart';
import 'package:authoros_core/procedural/generation_seed.dart';
import 'package:test/test.dart';

void main() {
  Phonology phonology() => starterPhonology();

  LanguageForgeWorkspace workspace() => LanguageForgeWorkspace.empty
      .withPhonology('lang-old', phonology())
      .withPhonology('lang-unmoved', phonology())
      .withScript(
        'script-old',
        ScriptMapping(
          writingSystemRecordId: 'script-old',
          glyphs: const [GlyphMapping(romanised: 'a', glyph: 'ᚨ')],
        ),
      )
      .withGrammar(
        'rule-old',
        const WordOrderFormula(languageId: 'lang-old'),
      )
      .withConvention(const NamingConvention(
        id: 'convention-1',
        name: 'Coastal',
        languageId: 'lang-old',
        scopeRecordId: 'culture-old',
      ))
      .withSoundChanges(const SoundChangeSet(
        id: 'changes-1',
        name: 'The drift',
        fromLanguageId: 'lang-old',
        toLanguageId: 'lang-unmoved',
        rules: ['k > h / _#'],
      ))
      .reserving(const ReservedWord(spelling: 'aran', languageId: 'lang-old'))
      .ignoring('Kael');

  const ids = {
    'lang-old': 'lang-new',
    'script-old': 'script-new',
    'rule-old': 'rule-new',
    'culture-old': 'culture-new',
  };

  group('remapIds', () {
    test('moves every record id the layer holds', () {
      final moved = workspace().remapIds(ids);

      expect(moved.phonologies.keys,
          unorderedEquals(['lang-new', 'lang-unmoved']));
      expect(moved.scripts.keys, ['script-new']);
      expect(moved.scripts['script-new']!.writingSystemRecordId, 'script-new');
      expect(moved.grammar.keys, ['rule-new']);
      expect(moved.grammar['rule-new']!.languageId, 'lang-new');
      expect(moved.conventions.single.languageId, 'lang-new');
      expect(moved.conventions.single.scopeRecordId, 'culture-new');
      expect(moved.soundChanges.single.fromLanguageId, 'lang-new');
      expect(moved.soundChanges.single.toLanguageId, 'lang-unmoved');
      expect(moved.reserved.single.languageId, 'lang-new');
      expect(moved.conventionsFor('lang-new'), hasLength(1));
      expect(moved.grammarBookFor('lang-new').wordOrder, isNotNull);
    });

    test('keeps the layer\'s own ids and what is not a record id', () {
      final moved = workspace().remapIds(ids);
      expect(moved.conventions.single.id, 'convention-1');
      expect(moved.soundChanges.single.id, 'changes-1');
      expect(moved.ignoredWords, {'kael'});
      expect(moved.reserved.single.spelling, 'aran');
    });

    test('the rules themselves survive the move', () {
      final before = workspace();
      final moved = before.remapIds(ids);
      final seed = GenerationSeed.phrase('river names');
      expect(
        WordForge.generate(moved.phonologies['lang-new']!, seed)
            .words
            .map((word) => word.spelling),
        WordForge.generate(before.phonologies['lang-old']!, seed)
            .words
            .map((word) => word.spelling),
      );
    });

    test('an empty map is the same workspace', () {
      final original = workspace();
      expect(identical(original.remapIds(const {}), original), isTrue);
    });

    test('moves a document it cannot read, leaving the rest intact', () {
      final document = {
        'schemaVersion': 99,
        'workspace': {
          'phonologies': {
            'lang-old': {'schemaVersion': 99, 'somethingNew': true},
          },
          'futureLayer': {'kept': true},
        },
      };
      final moved = LanguageForgeWorkspace.remapDocumentIds(document, ids);
      expect(moved['schemaVersion'], 99);
      final body = moved['workspace'] as Map;
      expect((body['phonologies'] as Map).keys, ['lang-new']);
      expect(body['futureLayer'], {'kept': true});
    });
  });

  group('documents', () {
    test('round trip', () {
      final read =
          LanguageForgeWorkspace.fromDocument(workspace().toDocument());
      expect(read.toJson(), workspace().toJson());
      expect(read.skippedOnRead, 0);
    });

    test('a newer schema reads as nothing, and says so', () {
      final read = LanguageForgeWorkspace.fromDocument({
        'schemaVersion': LanguageForgeWorkspace.schemaVersion + 1,
        'workspace': workspace().toJson(),
      });
      expect(read.isEmpty, isTrue);
      expect(read.skippedOnRead, 1);
    });

    test('missing or malformed is an empty workspace', () {
      expect(LanguageForgeWorkspace.fromDocument(null).isEmpty, isTrue);
      expect(LanguageForgeWorkspace.fromDocument('nonsense').isEmpty, isTrue);
      expect(
        LanguageForgeWorkspace.fromDocument({'workspace': 'nonsense'}).isEmpty,
        isTrue,
      );
    });
  });
}
