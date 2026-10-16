import 'dart:io';

import 'package:authoros_core/build_flags.dart';
import 'package:test/test.dart';

/// The flags are read at compile time, so what a test can hold is that each
/// one reads its own define, is off unless that define is given, and stays
/// `const`-shaped — the property every bundle check in AuthorOS Write rests
/// on. A flag routed through a getter or a variable would still pass the first
/// two and quietly put the room's code back into a build without it.
void main() {
  test('each flag reads its own define', () {
    expect(
      politicsAndPowerEnabled,
      const bool.fromEnvironment('AOS_ENABLE_POLITICS'),
    );
    expect(
      heartsAndTensionsEnabled,
      const bool.fromEnvironment('AOS_ENABLE_HEARTS'),
    );
    expect(
      languageForgeEnabled,
      const bool.fromEnvironment('AOS_ENABLE_LANGUAGE_FORGE'),
    );
  });

  test('Language Forge is off unless its define is given', () {
    if (const bool.hasEnvironment('AOS_ENABLE_LANGUAGE_FORGE')) {
      markTestSkipped('AOS_ENABLE_LANGUAGE_FORGE was defined for this run');
      return;
    }
    expect(languageForgeEnabled, isFalse);
  });

  test('every flag is a const read of bool.fromEnvironment', () {
    final source = File('lib/build_flags.dart').readAsStringSync();
    for (final (name, define) in const [
      ('politicsAndPowerEnabled', 'AOS_ENABLE_POLITICS'),
      ('heartsAndTensionsEnabled', 'AOS_ENABLE_HEARTS'),
      ('languageForgeEnabled', 'AOS_ENABLE_LANGUAGE_FORGE'),
    ]) {
      expect(
        RegExp(
          'const $name\\s*=\\s*bool\\.fromEnvironment\\(\'$define\'\\);',
        ).hasMatch(source),
        isTrue,
        reason: '$name must stay const-shaped',
      );
    }
  });

  test('no two flags share a define', () {
    final source = File('lib/build_flags.dart').readAsStringSync();
    final defines = RegExp(
      r"bool\.fromEnvironment\('([A-Z_]+)'\)",
    ).allMatches(source).map((m) => m.group(1)).toList();
    expect(defines.toSet(), hasLength(defines.length));
  });
}
