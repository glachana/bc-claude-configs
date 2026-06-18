# Audit de divergence du fork DynInter

> Généré le 2026-06-18. Base de comparaison : `upstream-v52` = v5.2.0 de Stefan Maron (`112a90b`).
> Objectif : reprendre la maîtrise de ce que le fork DynInter modifie par rapport à l'upstream.

## Synthèse

- **0 commit de retard, 24 d'avance** sur l'upstream. `master` contient l'intégralité du v5.2.0 + les ajouts DynInter, sans divergence emmêlée.
- **458 fichiers, +10856 / -4340.** Mais l'essentiel est **additif et vendoré** : à lui seul le corpus BCQuality pèse **396 fichiers / +8132** (de la donnée, pas du code à risque).
- Hors corpus : **62 fichiers, +2724 / -4340.** Les suppressions (-4340) sont majoritairement du **ménage légitime** de cruft upstream (backups, design notes, ancienne couche de specialists).
- Branches de sauvegarde présentes : `backup/before-bc-quality`, `backup/feature-DI1-pre-merge`.

**Conclusion : le fork n'est pas « en désordre ». C'est un fork additif, propre vis-à-vis de l'upstream, dont seules les docs de présentation (READMEs) sont périmées.**

---

## A. Système de citation BCQuality — apport majeur DynInter

Le bloc de valeur le plus important. Transforme les recommandations « de mémoire » des agents en citations traçables vers un corpus de règles.

| Élément | Fichiers | Rôle |
|---------|----------|------|
| Corpus vendoré | `bcquality/microsoft/`, `bcquality/community/` (396 fichiers) | Règles MS + communauté, citées par chemin |
| Index de citation | `bcquality/_index/{performance,privacy,security,style,testing,ui,upgrade}.md` | Récupération ciblée par domaine |
| Protocole | `skills/bcquality-citation/SKILL.md` (+167) | Modes DESIGN/GENERATE/CHECK, contrat `references[]`, gate de citation |
| Outillage | `scripts/build-bcquality-index.ps1`, `scripts/verify-citations.ps1`, `scripts/revendor-bcquality.ps1` | Build index, vérif citations, re-vendoring |
| Hook | `hooks/al-hook-verify-citations.sh` + `hooks/hooks.json` | Vérification automatique des citations |
| Intégration prompts | `reviewer-prompts.md` (+163), `al-developer-prompt.md` (+46), `test-engineer-prompts.md` (+38), `solution-architect-prompt.md` (+13), `docs-writer-prompt.md` (+4) | Chaque persona porte sa section BCQuality |

Commits : `7739ddf`, `5399ff3`, `310e7a6`, `2d737ed`.

## B. Consultation BC expert obligatoire

| Élément | Fichiers | Rôle |
|---------|----------|------|
| Protocole | `skills/bc-expert-consultation/SKILL.md` (+100) | Roster de specialists, mapping agent→specialist, gestion des échecs |
| Renforcement | prompts des personas | Consultation MCP `bc-code-intelligence-mcp` obligatoire avant tout livrable |

Commits : `349bf44`, `2d737ed`.

## C. Convention de nommage DynInter

| Élément | Fichiers | Rôle |
|---------|----------|------|
| Règle auto-chargée | `rules/al-naming.md` (+23) | Préfixe **uniquement**, jamais de suffixe ; défère à la règle custom |
| Règle canonique | `bcquality/custom/style/affix-as-prefix-on-custom-identifiers.{md,good.al,bad.al}` | Jurisprudence DynInter avec exemples bon/mauvais |

Commit : `739264e`.

## D. Ménage de l'upstream (suppressions intentionnelles)

Ces suppressions sont **voulues** — pas des pertes accidentelles :

| Supprimé | Lignes | Raison |
|----------|--------|--------|
| `bc-code-intel-knowledge/specialists/*` (alex, dean, pat, roger, sam×2, terry) + `coding-standards/` | ~2200 | Remplacé par le corpus BCQuality + knowledge bundlé du MCP (commit `7739ddf`) |
| `CLAUDE.md.v2-backup` | 1531 | Backup obsolète du refactor v3 |
| `.dev-v3-design.md` | 346 | Notes de design v3 |
| `TASK_SYSTEM_IMPROVEMENT_IDEA.md` | 166 | Note de brainstorming |
| `bc-code-intel-config.json` | 14 | Config de la couche knowledge locale supprimée |

## E. Infrastructure & nouvelles capacités

| Élément | Fichiers | Rôle |
|---------|----------|------|
| MCP | `.mcp.json` (+14/-14) | npx pour bc-code-intelligence-mcp, ajout nab-al-tools |
| LSP | `.lsp.json` (+10, nouveau) | Configuration LSP |
| Permissions | `.claude-plugin/settings.json` (+48) | Permissions + autoMode |
| Traduction | `skills/translate/SKILL.md` (+71, nouveau) | XLIFF via NAB AL Tools (défaut fr-FR) |
| Review PR ADO | `commands/review-pr.md` (+295, nouveau) | Review de PR Azure DevOps |
| Patterns de management | `skills/management-patterns/SKILL.md` (+276, nouveau) | Workflow Lead-as-Manager détaillé |
| CLI BC | `skills/bc-cli-tools/SKILL.md` (+164, nouveau) | Référence al-compile/bc-publish/bc-test |
| Onboarding | `docs/onboarding-windows.md` (+336, nouveau) | Guide d'installation Windows |
| Version | `plugin.json` → 5.2.2 | |

Commits : `f726fe7`, `6b3efaf`, `80f3209`, `7dcde2b`, et divers.

## F. Dette documentaire à corriger (le « ménage »)

| Fichier | Problème | Origine |
|---------|----------|---------|
| `profile-al-development/README.md` | Version **2.21.0** (plugin = 5.2.2), décrit 10 agents disparus et les commandes mortes `/dev-cycle`, `/estimate`, `/diagnostics`, `/docs-lookup`, `/nav-baseapp`, `/bc-expert` | **Hérité d'upstream** (jamais modifié) |
| `profile-al-development/agents/README.md` | Décrit la séquence des 11 agents v2 ; ne reste plus que `al-repo-summarizer` | Partiellement modifié, jamais terminé |
| `CLAUDE.md` (racine) | Section « Repository Structure » liste 11 agents + dossier `commands/` comme réels | Hérité, légèrement modifié |
| `skills/workflow-routing/SKILL.md`, `skills/task-coordination/SKILL.md` | Référencent `/dev-cycle` (commande inexistante) | Dette du refactor v3 |

> **Cause racine** : le refactor agents → équipes → skills (Stefan v3.0 → v5.x) a mis à jour le `CLAUDE.md` du plugin (chargé en contexte) mais pas les README, le `CLAUDE.md` racine ni certaines skills de plomberie (non relus car peu visibles).

## Statut du ménage (2026-06-18)

✅ Corrigé : `CLAUDE.md` racine (structure + diagramme), `profile-al-development/README.md`
(réécrit v5.2.2), `agents/README.md` (note de migration), références `/dev-cycle` mortes
dans `workflow-routing` et `task-coordination`.

⏳ Reste à décider : dérive de terminologie des **noms de rôles** dans les skills de
plomberie — `solution-planner` (renommé `solution-architect` en v3.0) et
`requirements-engineer` (persona supprimé, absorbé par `/interview` + `/plan`) apparaissent
encore dans `workflow-routing`, `proportional-planning` et `feedback-resolution`. Renommage
à confirmer avant application (modifie le comportement d'orchestration).

## Migration vers les serveurs MCP (2026-06-18)

Deux serveurs MCP DynInter publiés sur npm remplacent du contenu auparavant embarqué :

- **`bc-source-mcp`** (`npx -y bc-source-mcp`) — remplace la skill `bc-source` (clone git +
  grep manuel). 13 tools `bc_*`. Skill réécrite. Vérifié live (cache : branches `w1-28`,
  `w1-26`, `fr-28` indexées).
- **`bcquality-mcp`** (`npx -y bcquality-mcp`) — remplace le corpus vendoré `bcquality/`
  (410 fichiers), les scripts (`build-bcquality-index`, `verify-citations`, `revendor`) et le
  hook `al-hook-verify-citations`. Pointé sur le fork `DynamicsInternational/BCQuality` via
  `BCQUALITY_REPO_URL`. 10 tools `bcquality_*` ; workhorse `bcquality_get_applicable_for_context`.

Décisions appliquées : **tout migrer vers le MCP** (corpus vendoré supprimé) ; règle custom
DynInter `affix-as-prefix` **portée dans le fork** (`custom/knowledge/style/`) avant suppression
locale ; les deux serveurs **enregistrés dans `.mcp.json` du plugin**.

Le contrat de citation `[BCQuality: path]` est **préservé** — seul le retrieval change (appel
MCP au lieu de lecture fichier) ; les chemins cités restent re-vérifiables via
`bcquality_get_knowledge`. Fichiers touchés : `.mcp.json`, skills `bc-source` +
`bcquality-citation`, 4 prompts persona, `rules/al-naming.md`, `hooks/hooks.json`, plugin
`CLAUDE.md`, root `CLAUDE.md`, profil `README.md`.
</invoke>
