# Linting

## The command

```sh
dart analyze --plugins            # from the project root, no path arguments
dart analyze --plugins --fatal-infos   # CI / hard gate
```

Pair it with `flutter test` for behaviour.

## Why `flutter analyze` is not enough

`solid_lints` 1.0.0-dev.1 migrated off `custom_lint` to the SDK's native
`analysis_server_plugin` system. Its `analysis_options.yaml` therefore carries two kinds of rule:

- the `linter:` block — ordinary analyzer lint rules, which every analysis path honours;
- the `solid_lints: diagnostics:` block — rules implemented *inside the plugin*
  (`cyclomatic_complexity`, `avoid_non_null_assertion`, `avoid_duplicate_code`,
  `prefer_match_file_name`, `number_of_parameters`, `named_parameters_ordering`,
  `avoid_returning_widgets`, `no_empty_block`, `avoid_unused_parameters`, …).

The Dart Analysis Server loads analyzer plugins, which is why VS Code shows the second group. The
`dart analyze` CLI loads them only behind the `--plugins` flag, and `flutter analyze` has no such
flag at all — so `flutter analyze` reports "No issues found!" on code that violates a dozen
solid_lints diagnostics. That is a false pass, not a clean tree.

Two further sharp edges:

- **Path arguments disable the plugin.** `dart analyze --plugins lib test` reports nothing; the
  plugin is only picked up when the analysed context root is the package root. Always run bare.
- **Almost every solid_lints diagnostic is `info`,** so `dart analyze --plugins` exits 0 even when
  it prints findings. Use `--fatal-infos` wherever the exit code is what gets checked.

## Via the `dart` MCP server

`mcp__dart__analyze_files` drives the analysis server, so it is plugin-aware — but only when called
with the project `root` and **no `paths`**:

```json
{ "roots": [{ "root": "file:///absolute/path/to/e3dad-khodam-2026" }] }
```

Supplying `paths` narrows the context root and drops the plugin diagnostics exactly as the CLI does.

## Configuration note

The `plugins:` block in `analysis_options.yaml` must name an explicit version:

```yaml
plugins:
  solid_lints: 1.0.0-dev.1
```

A bare `solid_lints:` entry (as the package README shows) silently fails to resolve the plugin here,
and the plugin diagnostics disappear again.
