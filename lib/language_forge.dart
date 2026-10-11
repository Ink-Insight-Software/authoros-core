/// Language Forge's pure-Dart model: the Linguist's Study's engines and the
/// working layer they share.
///
/// Moved from AuthorOS Write's Language Forge expansion so AOS Worldsmith can
/// open the same Study over the same rules, and so the working layer can
/// travel in an archive. Each file is its own library; this one exports them
/// all for a caller that wants the room whole. Nothing here reads a store,
/// draws a random number or touches Flutter.
library;

export 'language_forge/grammar.dart';
export 'language_forge/guided_build.dart';
export 'language_forge/language_forge_workspace.dart';
export 'language_forge/language_profile.dart';
export 'language_forge/lexicon.dart';
export 'language_forge/lineage.dart';
export 'language_forge/linguistic_continuity.dart';
export 'language_forge/linguists_study_read_model.dart';
export 'language_forge/naming_conventions.dart';
export 'language_forge/phonology.dart';
export 'language_forge/phonology_text.dart';
export 'language_forge/script_mapping.dart';
export 'language_forge/sound_change.dart';
export 'language_forge/translation_workbench.dart';
export 'language_forge/word_forge.dart';
