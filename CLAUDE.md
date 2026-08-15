## Verifying changes

Run **`dart analyze --plugins` from the project root**, with no path arguments. Pair it with
`flutter test` for behaviour.

`solid_lints` 1.x ships its named diagnostics (`cyclomatic_complexity`, `avoid_non_null_assertion`,
`prefer_match_file_name`, …) as an analyzer plugin, and the CLI only loads plugins behind
`--plugins`. Without the flag — and that includes `flutter analyze`, which has no such flag —
those diagnostics are silently skipped and you get a false pass. Path arguments also drop them
(`dart analyze --plugins lib test` reports nothing), so always run at the root.

For CI or a hard gate use `dart analyze --plugins --fatal-infos`; most solid_lints diagnostics are
`info`, so a plain run exits 0 even with findings.

Via the `dart` MCP server, `analyze_files` with only the project `root` and **no `paths`** is
plugin-aware and equivalent; passing `paths` drops the plugin diagnostics the same way the CLI does.

More detail in `docs/agents/linting.md`.

## Where to work

Work in the main checkout. Do **not** run `EnterWorktree` unless the user asks for a worktree by
name — the user follows the work as it lands in their editor and their running app, and a separate
worktree hides every edit until the branch is merged back.

Background jobs are the one exception: that harness forces isolation before the first edit, and
once isolated it refuses the shared checkout entirely. If that applies, say so explicitly and name
the reason instead of isolating silently, and hand back the branch name and the merge command.

## Agent skills

### Issue tracker

Issues and specs live as markdown files under `.scratch/<feature-slug>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout — `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
