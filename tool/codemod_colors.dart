#!/usr/bin/env dart
//
// tool/codemod_colors.dart
//
// WHAT THIS IS FOR
// ----------------
// 23-02 moves ~277 colour reads off the static `GeniusWalletColors` palette
// class onto the semantic `context.gw` accessor (23-01). This is an AST
// rewriter, not a regex: it matches `PrefixedIdentifier`/`PropertyAccess`
// nodes whose prefix is exactly `GeniusWalletColors` and whose member is one
// of the 64 `GWColors` field names, so an occurrence inside a string
// literal, a doc comment, or a longer identifier cannot match -- that class
// of match simply does not exist at the node level `--self-test` proves it.
//
// NO PACKAGE INSTALL. This imports `package:analyzer` directly, which is
// already resolvable -- it arrives transitively via `build_runner` (confirmed
// in `.dart_tool/package_config.json`, analyzer-8.4.1) and needs zero change
// to `pubspec.yaml`/`pubspec.lock`. `depend_on_referenced_packages` is the
// expected, accepted complaint for that -- see the ignore below.
//
// WHY UNRESOLVED PARSING IS ENOUGH
// ---------------------------------
// This only rewrites an access *path* (`GeniusWalletColors.x` ->
// `context.gw.x`), never a value, so no type information is needed to decide
// *what* to rewrite. `package:analyzer`'s `Expression.inConstantContext` is a
// syntactic (not resolution-dependent) walk that is exactly the check needed
// to decide *whether* a site is safe to rewrite -- see the const-context
// refusal below.
//
// HARD REFUSALS (never rewritten, always reported)
// --------------------------------------------------
//   const      -- the site sits in a constant-expression context (an
//                 explicit `const` invocation/literal, a `const` variable's
//                 initializer, an annotation, or a default parameter value --
//                 defaults must themselves be compile-time constants even
//                 though `Expression.inConstantContext` alone doesn't flag
//                 them). `context.gw.x` is a runtime read; substituting it
//                 here is an "invalid constant value" compile error.
//   no-context -- no `BuildContext` is syntactically in scope: a `context`
//                 named parameter on the nearest enclosing method/constructor/
//                 closure, or (failing that) a non-static member of a class
//                 that `extends State<...>` (which inherits a `context`
//                 getter). Static members, top-level declarations, field
//                 initializers, and non-widget classes (controllers,
//                 painters, models) have neither and are refused.
//
// Anything under `lib/theme/` (the token layer itself, which legitimately
// reads its own primitives) is never even parsed for rewriting.
//
// USAGE
// -----
//   dart run tool/codemod_colors.dart --self-test
//   dart run tool/codemod_colors.dart --dry-run [dir]      # default dir: lib
//   dart run tool/codemod_colors.dart --apply <dir-or-file>
//
// `--dry-run` and `--apply` print a per-file report (sites rewritten/refused)
// followed by totals; `--apply` also rewrites files in place, back-to-front
// by offset within each file so earlier edits never invalidate later offsets.
//
// ignore_for_file: depend_on_referenced_packages -- `analyzer` arrives
// transitively via `build_runner` in the existing lockfile; this script is
// dev-only tooling that never ships, and adding it to `dev_dependencies`
// would be a package install (declined twice -- see 23-02-PLAN.md).
//
// ignore_for_file: avoid_print -- this is a `dart run` CLI tool, not
// production Flutter code; printing the per-file rewrite/refusal report to
// stdout IS its output contract (Task 1's `--dry-run` verify command reads
// it directly). Never ships as part of the app.

import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';

/// The legacy static palette class every rewrite moves off of.
const _legacyClass = 'GeniusWalletColors';

/// The 64 `GWColors` field names this codemod rewrites onto
/// `context.gw.<name>`. Sourced from `lib/theme/gw_colors.dart`'s field list
/// (23-01's parity extension). `statusNeutral` is deliberately excluded --
/// it has no `GWColors` counterpart (see 23-01-TOKEN-MAP.md's "Excluded"
/// section: its glyph colour is derived from the fill, a second hand
/// maintained token would fork that derivation) -- so it is left untouched,
/// still reading `GeniusWalletColors.statusNeutral`.
const Set<String> _tokenNames = {
  'surfaceBase',
  'surfaceElevated',
  'surfaceMenu',
  'surfaceSunken',
  'surfaceOverlay',
  'textPrimary',
  'textPrimary80',
  'textPrimary70',
  'textPrimary60',
  'textPrimary54',
  'textPrimary38',
  'textPrimary30',
  'textPrimary24',
  'textPrimary12',
  'textPrimary10',
  'textSecondary',
  'statusSuccess',
  'statusError',
  'borderSubtle',
  'borderStrong',
  'borderControl',
  'lightGreenPrimary',
  'lightGreenSecondary',
  'mutedGreen',
  'deepBlueTertiary',
  'deepBlueCardColor',
  'deepBlueMenu',
  'deepBlue',
  'grayPrimary',
  'btnText',
  'btnDisabled',
  'btnTextDisabled',
  'btnGradientBlue',
  'btnGradientGreen',
  'btnFilter',
  'btnFilterSelected',
  'foundationError',
  'borderGrey',
  'brandPrimary',
  'brandPrimaryStrong',
  'brandPrimaryMuted',
  'brandPrimarySubtle',
  'brandPrimaryOnSurface',
  'brandSecondary',
  'brandSecondaryStrong',
  'brandSecondaryBright',
  'brandSecondaryMuted',
  'brandSecondarySubtle',
  'brandTertiary',
  'brandTertiaryMuted',
  'brandTertiarySubtle',
  'gradientBlue',
  'gradientGreen',
  'gray500',
  'textTertiary',
  'textDisabled',
  'textOnBrand',
  'borderBrand',
  'statusWarning',
  'statusInfo',
  'brandGreen',
  'brandGreenStrong',
  'brandGreenMuted',
  'brandGreenSubtle',
};

/// A site the codemod will rewrite: `GeniusWalletColors.<symbol>` spanning
/// `[offset, end)` in the file's original content, on 1-based `line`.
class RewriteSite {
  RewriteSite(this.offset, this.end, this.symbol, this.line);
  final int offset;
  final int end;
  final String symbol;
  final int line;
}

/// A site the codemod refuses to touch, with a machine-readable [reason]:
/// `'const'` or `'no-context'`.
class RefusalSite {
  RefusalSite(this.path, this.line, this.symbol, this.reason);
  final String path;
  final int line;
  final String symbol;
  final String reason;
}

/// One `import` directive's URI and its `[offset, end)` span in the
/// ORIGINAL file content -- imports always sit before any expression that
/// could be rewritten, so these offsets stay valid after body rewrites are
/// applied (see `applyReport`).
class ImportInfo {
  ImportInfo(this.offset, this.end, this.uri);
  final int offset;
  final int end;
  final String uri;
}

/// Result of scanning one file: what it would rewrite, what it refuses, its
/// existing imports (for import bookkeeping), and whether every
/// `GeniusWalletColors` reference in the file -- migrated or not -- was
/// accounted for as a rewrite (used to decide whether the legacy import
/// becomes dead).
class FileReport {
  FileReport(
    this.path,
    this.rewrites,
    this.refusals,
    this.imports,
    this.totalLegacyRefs,
  );
  final String path;
  final List<RewriteSite> rewrites;
  final List<RefusalSite> refusals;
  final List<ImportInfo> imports;
  final int totalLegacyRefs;
}

/// Walks a parsed compilation unit looking for `GeniusWalletColors.<token>`
/// access paths, classifying each as a rewrite or one of the two refusals.
class _ColorAccessVisitor extends RecursiveAstVisitor<void> {
  _ColorAccessVisitor(this.path, this.lineInfo);

  final String path;
  final LineInfo lineInfo;
  final List<RewriteSite> rewrites = [];
  final List<RefusalSite> refusals = [];

  /// Every `GeniusWalletColors.<anything>` reference seen, including names
  /// outside the 64-name token map (e.g. `statusNeutral`). If this count
  /// exceeds `rewrites.length`, something still needs the legacy import
  /// after this codemod runs.
  int totalLegacyRefs = 0;

  void _consider(
    Expression node,
    SimpleIdentifier prefix,
    SimpleIdentifier property,
  ) {
    if (prefix.name != _legacyClass) {
      return;
    }
    totalLegacyRefs++;
    final symbol = property.name;
    if (!_tokenNames.contains(symbol)) {
      // Not one of the 64 migrated names (e.g. `statusNeutral`) -- leave
      // untouched, and not part of this plan's rewritten-vs-refused count.
      return;
    }

    final line = lineInfo.getLocation(node.offset).lineNumber;

    if (node.inConstantContext || _isDefaultParamValue(node)) {
      refusals.add(RefusalSite(path, line, symbol, 'const'));
      return;
    }
    if (!_contextAvailable(node)) {
      refusals.add(RefusalSite(path, line, symbol, 'no-context'));
      return;
    }
    rewrites.add(RewriteSite(node.offset, node.end, symbol, line));
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _consider(node, node.prefix, node.identifier);
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final target = node.target;
    if (target is SimpleIdentifier) {
      _consider(node, target, node.propertyName);
    }
    super.visitPropertyAccess(node);
  }
}

/// True if [node] sits inside a `DefaultFormalParameter`'s default-value
/// expression, without having crossed into a real function body first.
/// `Expression.inConstantContext` explicitly does NOT count this case (see
/// its doc comment), but a default value must itself be a compile-time
/// constant, so it is refused here as its own check.
bool _isDefaultParamValue(AstNode node) {
  AstNode? current = node;
  AstNode? parent = current.parent;
  while (parent != null) {
    if (parent is DefaultFormalParameter) {
      return true;
    }
    if (parent is FunctionBody) {
      return false;
    }
    current = parent;
    parent = parent.parent;
  }
  return false;
}

bool _hasContextParam(FormalParameterList? params) {
  if (params == null) {
    return false;
  }
  for (final p in params.parameters) {
    if (p.name?.lexeme == 'context') {
      return true;
    }
  }
  return false;
}

/// True if a `BuildContext` named `context` is syntactically reachable from
/// [node]: a `context` parameter on the nearest enclosing
/// method/constructor/closure, or -- failing that -- a non-static member of a
/// class that `extends State<...>` (which inherits a `context` getter).
bool _contextAvailable(AstNode node) {
  AstNode? current = node.parent;
  bool? nearestMemberStatic;
  while (current != null) {
    if (current is FunctionExpression) {
      if (_hasContextParam(current.parameters)) {
        return true;
      }
    } else if (current is MethodDeclaration) {
      if (_hasContextParam(current.parameters)) {
        return true;
      }
      nearestMemberStatic ??= current.isStatic;
    } else if (current is ConstructorDeclaration) {
      if (_hasContextParam(current.parameters)) {
        return true;
      }
      nearestMemberStatic ??= false;
    } else if (current is FieldDeclaration ||
        current is TopLevelVariableDeclaration) {
      // An initializer expression -- `this` (and so an inherited `context`
      // getter) isn't available here in Dart, and there's no enclosing
      // method to have declared a `context` parameter either.
      return false;
    } else if (current is ClassDeclaration) {
      final superName = current.extendsClause?.superclass.name.lexeme;
      return superName == 'State' && nearestMemberStatic == false;
    }
    current = current.parent;
  }
  return false;
}

/// Parses [content] and returns the rewrite/refusal report for [path].
/// Returns `null` if the content doesn't parse cleanly (never expected on
/// this repo's analyzer-clean tree; surfaced rather than silently skipped).
FileReport? scanContent(String path, String content) {
  final result = parseString(
    content: content,
    path: path,
    throwIfDiagnostics: false,
  );
  if (result.errors.isNotEmpty) {
    stderr.writeln(
      'PARSE ERROR: $path: ${result.errors.map((e) => e.toString()).join('; ')}',
    );
    return null;
  }
  final visitor = _ColorAccessVisitor(path, result.lineInfo);
  result.unit.accept(visitor);

  final imports = <ImportInfo>[];
  for (final directive in result.unit.directives) {
    if (directive is ImportDirective) {
      final uri = directive.uri.stringValue;
      if (uri != null) {
        imports.add(ImportInfo(directive.offset, directive.end, uri));
      }
    }
  }

  return FileReport(
    path,
    visitor.rewrites,
    visitor.refusals,
    imports,
    visitor.totalLegacyRefs,
  );
}

FileReport? scanFile(String path) {
  final content = File(path).readAsStringSync();
  return scanContent(path, content);
}

const _contextExtensionUri =
    'package:genius_wallet/theme/gw_context_extension.dart';
const _legacyImportUri =
    'package:genius_wallet/theme/genius_wallet_colors.dart';

/// Returns the offset at which to insert a new import with URI [newUri],
/// keeping the file's existing alphabetical `import` ordering (this repo's
/// `directives_ordering` lint requires it). Returns the offset of the first
/// existing import that sorts after [newUri], or just past the last import
/// (by its position in the file) if [newUri] sorts last.
int _importInsertionOffset(List<ImportInfo> imports, String newUri) {
  if (imports.isEmpty) {
    return 0;
  }
  final byUri = [...imports]..sort((a, b) => a.uri.compareTo(b.uri));
  for (final imp in byUri) {
    if (newUri.compareTo(imp.uri) < 0) {
      return imp.offset;
    }
  }
  final lastByPosition = imports.reduce((a, b) => a.end > b.end ? a : b);
  return lastByPosition.end + 1;
}

/// Applies [report]'s rewrites to [path]'s content, back-to-front by offset
/// so earlier edits never invalidate later offsets, then reconciles the two
/// imports every rewrite site depends on:
///   - adds `gw_context_extension.dart` (for `context.gw`) if this file
///     didn't already have it and at least one rewrite happened.
///   - drops the legacy `genius_wallet_colors.dart` import if every
///     `GeniusWalletColors` reference in the file (rewrites + refusals +
///     excluded names) was a rewrite, i.e. nothing is left that still needs
///     it.
/// Writes the result. No-ops entirely if there was nothing to rewrite.
void applyReport(String path, FileReport report) {
  if (report.rewrites.isEmpty) {
    return;
  }
  var content = File(path).readAsStringSync();

  // 1. Body rewrites, back-to-front. All offsets here are strictly after
  //    the import block, so the import bookkeeping below (computed from the
  //    same original parse) stays valid through this step.
  final sortedRewrites = [...report.rewrites]
    ..sort((a, b) => b.offset.compareTo(a.offset));
  for (final site in sortedRewrites) {
    content = content.replaceRange(
      site.offset,
      site.end,
      'context.gw.${site.symbol}',
    );
  }

  // 2. Import bookkeeping.
  final needsContextImport = !report.imports.any(
    (i) => i.uri == _contextExtensionUri,
  );
  final legacyImports = report.imports.where((i) => i.uri == _legacyImportUri);
  final legacyNowDead =
      report.totalLegacyRefs == report.rewrites.length &&
      legacyImports.isNotEmpty;

  var insertOffset = needsContextImport
      ? _importInsertionOffset(report.imports, _contextExtensionUri)
      : -1;

  if (legacyNowDead) {
    final imp = legacyImports.single;
    var end = imp.end;
    if (end < content.length && content[end] == '\n') {
      end++;
    }
    final start = imp.offset;
    content = content.replaceRange(start, end, '');
    if (insertOffset >= end) {
      insertOffset -= end - start;
    } else if (insertOffset > start) {
      // Shouldn't happen (insertion offset always targets some OTHER
      // import's start), but never insert into the middle of a span we
      // just deleted.
      insertOffset = start;
    }
  }

  if (needsContextImport) {
    content = content.replaceRange(
      insertOffset,
      insertOffset,
      "import '$_contextExtensionUri';\n",
    );
  }

  File(path).writeAsStringSync(content);
}

/// All `.dart` files under [dir], excluding `lib/theme/` (the token layer
/// itself -- a hard refusal, never even parsed for rewriting).
List<String> _dartFiles(String dir) {
  final entity = FileSystemEntity.typeSync(dir);
  if (entity == FileSystemEntityType.file) {
    return [dir];
  }
  final files = <String>[];
  for (final e in Directory(dir).listSync(recursive: true)) {
    if (e is! File || !e.path.endsWith('.dart')) {
      continue;
    }
    final normalized = e.path.replaceAll('\\', '/');
    if (normalized.contains('/theme/') || normalized.startsWith('lib/theme/')) {
      continue;
    }
    files.add(normalized);
  }
  files.sort();
  return files;
}

void _printReport(List<FileReport> reports, {required bool dryRun}) {
  var totalRewrites = 0;
  var totalConst = 0;
  var totalNoContext = 0;
  for (final r in reports) {
    if (r.rewrites.isEmpty && r.refusals.isEmpty) {
      continue;
    }
    print(
      '${r.path}: ${r.rewrites.length} rewritten, ${r.refusals.length} refused',
    );
    for (final s in r.rewrites) {
      print('  REWRITE line ${s.line}: $_legacyClass.${s.symbol}');
    }
    for (final s in r.refusals) {
      print(
        '  REFUSE  line ${s.line}: $_legacyClass.${s.symbol} (${s.reason})',
      );
    }
    totalRewrites += r.rewrites.length;
    totalConst += r.refusals.where((s) => s.reason == 'const').length;
    totalNoContext += r.refusals.where((s) => s.reason == 'no-context').length;
  }
  print('');
  if (dryRun) {
    print('DRY RUN -- no files written.');
  }
  print('Sites rewritten: $totalRewrites');
  print('Sites refused (const): $totalConst');
  print('Sites refused (no-context): $totalNoContext');
  print('Total sites seen: ${totalRewrites + totalConst + totalNoContext}');
}

void _runDryRun(String dir) {
  final reports = <FileReport>[];
  for (final path in _dartFiles(dir)) {
    final r = scanFile(path);
    if (r != null) {
      reports.add(r);
    }
  }
  _printReport(reports, dryRun: true);
}

void _runApply(String target) {
  final reports = <FileReport>[];
  for (final path in _dartFiles(target)) {
    final r = scanFile(path);
    if (r == null) {
      continue;
    }
    applyReport(path, r);
    reports.add(r);
  }
  _printReport(reports, dryRun: false);
}

// ---------------------------------------------------------------------------
// --self-test
// ---------------------------------------------------------------------------

int _runSelfTest() {
  var failures = 0;

  void check(String name, bool condition) {
    if (condition) {
      print('PASS: $name');
    } else {
      print('FAIL: $name');
      failures++;
    }
  }

  // Case 1: a plain access inside build() is rewritten.
  final case1 = scanContent('case1.dart', '''
class Foo extends StatelessWidget {
  const Foo({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(color: GeniusWalletColors.brandPrimary);
  }
}
''')!;
  check(
    '1-plain-access-rewritten',
    case1.rewrites.length == 1 &&
        case1.rewrites.single.symbol == 'brandPrimary',
  );
  check('1-plain-access-no-refusals', case1.refusals.isEmpty);

  // Case 2: an access inside an explicit const invocation is refused (const).
  final case2 = scanContent('case2.dart', '''
class Foo extends StatelessWidget {
  const Foo({super.key});
  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: GeniusWalletColors.brandPrimary);
  }
}
''')!;
  check(
    '2-const-invocation-refused',
    case2.rewrites.isEmpty &&
        case2.refusals.length == 1 &&
        case2.refusals.single.reason == 'const',
  );

  // Case 2b: a top-level `const` variable's initializer is refused (const),
  // even with no explicit `const` keyword on the list literal itself.
  final case2b = scanContent('case2b.dart', '''
const List<Color> kColors = [GeniusWalletColors.brandPrimary];
''')!;
  check(
    '2b-const-toplevel-var-refused',
    case2b.rewrites.isEmpty &&
        case2b.refusals.length == 1 &&
        case2b.refusals.single.reason == 'const',
  );

  // Case 3: an identically-spelled occurrence inside a string literal is not
  // matched at all (not a rewrite, not a refusal -- it was never a node).
  final case3 = scanContent('case3.dart', '''
const x = 'GeniusWalletColors.brandPrimary';
''')!;
  check(
    '3-string-literal-not-matched',
    case3.rewrites.isEmpty && case3.refusals.isEmpty,
  );

  // Case 4: an identically-spelled occurrence inside a comment is not
  // matched at all.
  final case4 = scanContent('case4.dart', '''
// GeniusWalletColors.brandPrimary
const y = 1;
''')!;
  check(
    '4-comment-not-matched',
    case4.rewrites.isEmpty && case4.refusals.isEmpty,
  );

  // Case 5: no BuildContext in scope -- a top-level constant is refused
  // (no-context), distinct from a const refusal.
  final case5 = scanContent('case5.dart', '''
final Color notConst = GeniusWalletColors.brandPrimary;
''')!;
  check(
    '5-toplevel-no-context-refused',
    case5.rewrites.isEmpty &&
        case5.refusals.length == 1 &&
        case5.refusals.single.reason == 'no-context',
  );

  // Case 6: a static field with no BuildContext is refused (no-context).
  final case6 = scanContent('case6.dart', '''
class Foo {
  static Color get glyph => GeniusWalletColors.brandPrimaryOnSurface;
}
''')!;
  check(
    '6-static-member-no-context-refused',
    case6.rewrites.isEmpty &&
        case6.refusals.length == 1 &&
        case6.refusals.single.reason == 'no-context',
  );

  // Case 7: a non-static instance method of a State subclass, with no
  // explicit `context` parameter, is rewritten via the inherited getter.
  final case7 = scanContent('case7.dart', '''
class _FooState extends State<Foo> {
  void _onTap() {
    final c = GeniusWalletColors.brandPrimary;
  }
}
''')!;
  check(
    '7-state-subclass-implicit-context-rewritten',
    case7.rewrites.length == 1 && case7.refusals.isEmpty,
  );

  // Case 8: a CustomPainter (not a State subclass, no context param) is
  // refused (no-context).
  final case8 = scanContent('case8.dart', '''
class FooPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = GeniusWalletColors.brandPrimary;
  }
}
''')!;
  check(
    '8-painter-no-context-refused',
    case8.rewrites.isEmpty &&
        case8.refusals.length == 1 &&
        case8.refusals.single.reason == 'no-context',
  );

  // Case 9: a name not in the token map (statusNeutral) is left alone
  // entirely -- neither rewritten nor reported as a refusal.
  final case9 = scanContent('case9.dart', '''
class Foo extends StatelessWidget {
  const Foo({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(color: GeniusWalletColors.statusNeutral);
  }
}
''')!;
  check(
    '9-excluded-name-untouched',
    case9.rewrites.isEmpty && case9.refusals.isEmpty,
  );

  // Case 10 (apply, real files): applying a rewrite adds the
  // `gw_context_extension.dart` import and drops the now-dead legacy import
  // when nothing else in the file still needs it.
  final tmp10 = Directory.systemTemp.createTempSync('codemod_colors_test_10');
  final file10 = File('${tmp10.path}/case10.dart');
  file10.writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class Foo extends StatelessWidget {
  const Foo({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(color: GeniusWalletColors.brandPrimary);
  }
}
''');
  final report10 = scanFile(file10.path)!;
  applyReport(file10.path, report10);
  final rewritten10 = file10.readAsStringSync();
  check(
    '10-apply-adds-context-import',
    rewritten10.contains(
      "import 'package:genius_wallet/theme/gw_context_extension.dart';",
    ),
  );
  check(
    '10-apply-drops-dead-legacy-import',
    !rewritten10.contains('genius_wallet_colors.dart'),
  );
  check(
    '10-apply-rewrites-body',
    rewritten10.contains('context.gw.brandPrimary'),
  );
  tmp10.deleteSync(recursive: true);

  // Case 11 (apply, real files): when a refusal remains (here, a const
  // site), the legacy import stays -- it's still needed.
  final tmp11 = Directory.systemTemp.createTempSync('codemod_colors_test_11');
  final file11 = File('${tmp11.path}/case11.dart');
  file11.writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class Foo extends StatelessWidget {
  const Foo({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(color: GeniusWalletColors.brandPrimary),
        const ColoredBox(color: GeniusWalletColors.brandSecondary),
      ],
    );
  }
}
''');
  final report11 = scanFile(file11.path)!;
  applyReport(file11.path, report11);
  final rewritten11 = file11.readAsStringSync();
  check(
    '11-apply-keeps-legacy-import-when-still-needed',
    rewritten11.contains('genius_wallet_colors.dart') &&
        rewritten11.contains('GeniusWalletColors.brandSecondary'),
  );
  check(
    '11-apply-adds-context-import-alongside-legacy',
    rewritten11.contains('gw_context_extension.dart') &&
        rewritten11.contains('context.gw.brandPrimary'),
  );
  tmp11.deleteSync(recursive: true);

  print('');
  if (failures == 0) {
    print('All self-test cases passed.');
  } else {
    print('$failures self-test case(s) FAILED.');
  }
  return failures == 0 ? 0 : 1;
}

void main(List<String> args) {
  if (args.isEmpty || args.first == '--dry-run') {
    final dir = args.length > 1 ? args[1] : 'lib';
    _runDryRun(dir);
    return;
  }
  switch (args.first) {
    case '--self-test':
      exit(_runSelfTest());
    case '--apply':
      if (args.length < 2) {
        stderr.writeln(
          'usage: dart run tool/codemod_colors.dart --apply <dir-or-file>',
        );
        exit(2);
      }
      _runApply(args[1]);
    default:
      stderr.writeln(
        'usage: dart run tool/codemod_colors.dart [--dry-run [dir]|--apply <dir-or-file>|--self-test]',
      );
      exit(2);
  }
}
