## Verifying changes

Run **`flutter analyze` from the project root**, with no path arguments.

This project lints with `solid_lints`, and those rules only load when analysis runs at the root. A
scoped run (`dart analyze lib test`, or analysing a subdirectory) reports "No issues found!" while
genuinely violating solid_lints rules — a false pass. Pair it with `flutter test` for behaviour.

## Agent skills

### Issue tracker

Issues and specs live as markdown files under `.scratch/<feature-slug>/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default five canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout — `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
