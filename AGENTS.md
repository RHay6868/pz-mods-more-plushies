# AGENTS.md

Instructions for any AI agent (Codex, Claude, or other) working in this repo.
Read this whole file before making changes.

## What this repo is

- Mod: **{{MOD_NAME}}** (mod ID `{{MOD_ID}}`)
- Target: Project Zomboid **Build 42** (current stable: {{PZ_VERSION}})
- Author / owner: RHAY (Mark Flynn). All rights reserved; see LICENSE.
- B41 source of truth (read-only): {{B41_REPO_URL}} at tag `b41-final`
- Workshop item: {{WORKSHOP_ID_OR_TBD}}

This repo is a B42 rebuild. The B41 repo is reference material only.
Never commit to the B41 repo from a B42 task.

## Repo layout

The repo root IS the Workshop upload folder, so it can be cloned or
symlinked straight into `~/Zomboid/Workshop/`.

```
{{REPO_NAME}}/
├── preview.png                 Workshop thumbnail (256x256)
├── workshop.txt                Workshop metadata (ID, title, description)
├── Contents/mods/{{MOD_FOLDER}}/
│   ├── common/                 Version-independent assets (may hold only .gitkeep)
│   └── 42/
│       ├── mod.info
│       ├── poster.png
│       ├── icon.png
│       └── media/
│           ├── lua/{client,server,shared}/
│           ├── scripts/
│           ├── textures/
│           ├── models_X/
│           ├── clothing/        (clothing mods only)
│           ├── sound/
│           └── lua/shared/Translate/EN/
├── art-src/                    Source art (.blend, .psd); not shipped
├── docs/
│   ├── CONVERSION.md           B41 -> B42 inventory and decisions log
│   └── TESTING.md              In-game test checklist
├── CHANGELOG.md
├── AGENTS.md
├── README.md
└── LICENSE
```

## Ground rules

1. **Vanilla B42 is the source of truth for syntax.** Before writing any item
   script, craftRecipe, fluid definition, distribution, translation file, or
   mod.info field, check how vanilla does it in `reference/` (local extract of
   the game's `media/`, gitignored). Do not write B42 syntax from memory or
   from B41 patterns. If `reference/` is missing, stop and say so.
2. **No B41 leftovers.** Old-style `recipe` blocks, B41 fluid properties
   (`ReplaceOnUse`-style liquid chains, `UseDelta` drinks, etc.), and B41-only
   Lua APIs must be converted or removed, not left beside the new code.
3. **Namespace everything.** Lua globals, module names, item IDs, sandbox
   options, and event handlers use the `{{PREFIX}}` prefix. No bare globals.
4. **Client / server / shared split is deliberate.** Anything that changes
   world state, inventory, or another player in MP runs server side and is
   requested via `sendClientCommand` / handled in `OnClientCommand`.
   Random rolls that other players see are rolled on the server.
5. **Do not touch vanilla files or override vanilla functions wholesale.**
   Hook and call the original. Note every hook in `docs/CONVERSION.md`.
6. **Balance values are owner decisions.** Agents may propose numbers with
   the math shown, but do not silently change damage, weights, spawn rates,
   or nutrition. Flag them in the PR description.
7. **Assets:** never re-export or "optimize" textures/models unless asked.
   Never add third-party assets.
8. **Keep IDs stable.** Once an item ID ships on the Workshop, it does not
   get renamed without a migration note, because renames break saves.

## Workflow

- Branches: `main` is always loadable in game. Work on `feat/*`, `fix/*`,
  `port/*` branches. One logical change per commit.
- Commit messages: `type(scope): summary` (types: port, feat, fix, balance,
  art, docs, chore).
- Every port task updates `docs/CONVERSION.md` (what was converted, what was
  dropped, what changed and why).
- Every change that affects gameplay adds a line to `CHANGELOG.md` under
  `Unreleased`.
- Agents cannot run the game. Say exactly what needs in-game verification and
  add it to `docs/TESTING.md`. Do not claim something works in game.

## Review

Implementation and review are done by different agents/sessions. The
reviewer reads the commit, checks it against this file and vanilla
`reference/`, and reports findings without editing. Findings are
reconciled before the next phase.

## Mod-specific notes

{{MOD_SPECIFIC_NOTES}}
