---
name: translate
description: Translate an AL project's XLIFF localization files using the NAB AL Tools MCP. Defaults to French (fr-FR); accepts any target language. Syncs the generated .g.xlf, fills untranslated units while preserving AL placeholders and locked labels, applies the BC glossary for terminology consistency, and saves back to the language XLF.
---

# /translate — AL XLIFF Localization

Translate the project's AL translation units. **Default target: French (`fr-FR`).** A
different or additional language can be requested via `$ARGUMENTS`
(e.g. `/translate de-DE`, `/translate fr-CA es-ES`).

Powered by the **`nab-al-tools`** MCP server (XLIFF management). The MCP handles file
I/O and state; **you** produce the translations.

## Prerequisites

- `nab-al-tools` MCP available (npx `@nabsolutions/nab-al-tools-mcp`, Node ≥ 20).
- The project has a generated base file `Translations/<App>.g.xlf` (produced by
  compiling with the `TranslationFile` feature). If absent, compile first (`/compile`)
  so the `.g.xlf` exists.

## Resolve the target language

1. Parse `$ARGUMENTS` for one or more BCP-47 codes (`fr-FR`, `fr-CA`, `de-DE`, …).
2. If none given → **default `fr-FR`**. If the project already has a French XLF with a
   different region (e.g. `fr-CA`), prefer the existing one and say so.
3. For each target, if `Translations/<App>.<lang>.xlf` does not exist, create it with
   `createLanguageXlf`.

## Workflow (per target language)

1. **Sync** — `refreshXlf` to align the language XLF with the latest `.g.xlf` (picks up
   new/changed/removed units; marks stale ones).
2. **Glossary** — `getGlossaryTerms` to load BC terminology. Translate covered terms
   consistently with the glossary (e.g. *Posting* → *Validation* in fr; never invent a
   competing term).
3. **Fetch** — `getTextsToTranslate` to get the untranslated / needs-translation units.
   For partial passes, `getTranslatedTextsByState` to target a specific state.
4. **Translate** — produce the target text for each unit, honoring the rules below.
5. **Save** — `saveTranslatedTexts` in batches (set state to `translated`, or
   `needs-review-translation` when you are unsure so a human reviews it).
6. **Report** — counts per language: translated, left for review, skipped (locked),
   and any units that exceeded `maxwidth`.

## Translation rules (non-negotiable for AL)

- **Preserve placeholders verbatim** — `%1`, `%2`, `#1`, `@1`, `{0}` and the like are
  runtime substitutions. Keep them, keep their order meaningful, never translate them.
- **Locked labels** — never translate a unit whose `Locked`/`translate=no` is set (codes,
  option values used as keys, technical tokens). Skip and count them.
- **Respect `maxwidth`** — if a unit declares a max length, keep the translation within it;
  flag any that cannot fit instead of silently truncating.
- **Keep terminology consistent** — same source term → same target term across the file;
  defer to the glossary, then to the existing BC standard translation.
- **Don't translate object/field identifiers** — only the human-facing caption/tooltip text.
- **Tone** — match Business Central UI register (concise, formal-neutral). For `fr-CA`
  vs `fr-FR`, follow the region's BC conventions when a glossary distinction exists.
- **Uncertain → needs-review** — when meaning is ambiguous without context, translate
  best-effort and set `needs-review-translation` rather than guessing silently.

## Multiple languages

Process each target language as an independent pass (sync → translate → save) and give a
combined summary table at the end. Languages do not share state beyond the shared `.g.xlf`.

## Notes

- This skill is localization-only; it does not compile or publish. Run `/compile` first if
  the `.g.xlf` is stale.
- For a sanity pass on existing translations (not just empty ones), use
  `getTranslatedTextsByState` to pull `needs-review-translation` and revisit them.
