# Onboarding Windows — Claude Code + profil AL (Business Central)

Guide d'installation pas-à-pas pour mettre en place Claude Code et le plugin
`profile-al-development` sur un poste **Windows**. À suivre de haut en bas.

> Public : développeurs AL/BC de Dynamics International.
> Durée : ~30–45 min (hors téléchargements).

---

## 0. Vue d'ensemble — les couches à installer

```
┌─ Couche système ──────────────────────────────────────────────┐
│  Node.js · Git · VS Code · .NET SDK                            │
├─ Outils AL ───────────────────────────────────────────────────┤
│  Extension AL Language (VS Code)  →  fournit alc.exe + analyzers│
│  LinterCop (analyzer communautaire, optionnel)                 │
├─ Claude Code ─────────────────────────────────────────────────┤
│  CLI claude (installeur natif) + authentification              │
├─ Plugin / config ─────────────────────────────────────────────┤
│  Clone du repo bc-claude-configs + .claude/settings.json projet │
├─ Serveurs MCP ────────────────────────────────────────────────┤
│  microsoft_docs_mcp (HTTP)       │ rien à installer            │
│  al-mcp-server (npx)             │ auto (Node)                 │
│  bc-code-intelligence-mcp (npx)  │ auto (Node)                 │
│  alcops (alcops-mcp)             │ dotnet tool                 │
├─ Outils .NET (dotnet tools) ──────────────────────────────────┤
│  alcops-mcp · al-runner · al-mutate  → dotnet tool install     │
├─ Outils CLI build/test ───────────────────────────────────────┤
│  al-compile      → StefanMaron/al-smart-compile (install.ps1)  │
│  bc-publish/bc-test → intégration BC via Docker (bc-linux, §9) │
└────────────────────────────────────────────────────────────────┘
```

---

## 1. Prérequis système

Installer (si absents) puis **vérifier**. Commandes de vérif dans un terminal
PowerShell :

| Outil | Installation | Vérification |
|-------|--------------|--------------|
| **Node.js** (LTS) | https://nodejs.org → installeur Windows (cocher « Add to PATH ») | `node -v` et `npm -v` |
| **Git** | https://git-scm.com/download/win | `git --version` |
| **VS Code** | https://code.visualstudio.com | `code --version` |
| **.NET SDK** (8.0+) | https://dotnet.microsoft.com/download | `dotnet --version` |

```powershell
# Vérification groupée
node -v; npm -v; git --version; dotnet --version; code --version
```

Tout doit renvoyer une version. Si une commande est « introuvable », fermer/rouvrir
le terminal (le PATH n'est rafraîchi qu'au redémarrage du shell).

---

## 2. Extension AL Language (VS Code)

`al-compile` utilise le compilateur (`alc.exe`) et les analyzers fournis **par
l'extension AL**. Sans elle, pas de compilation.

1. Ouvrir VS Code → onglet **Extensions** (`Ctrl+Shift+X`)
2. Rechercher **AL Language** (éditeur : `ms-dynamics-smb`)
3. **Installer**

Vérification :

```powershell
Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Filter "ms-dynamics-smb.al-*" -Directory |
  Select-Object Name
```

→ doit lister au moins un dossier `ms-dynamics-smb.al-<version>`.

### LinterCop (optionnel mais recommandé)

Analyzer communautaire utilisé par défaut par `al-compile`. S'il est absent,
`al-compile` l'ignore silencieusement (pas d'erreur).

- Télécharger `BusinessCentral.LinterCop.dll` :
  https://github.com/StefanMaron/BusinessCentral.LinterCop/releases
- Le copier dans le dossier `bin\Analyzers\` de l'extension AL la plus récente :

```powershell
$alExt = Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Filter "ms-dynamics-smb.al-*" -Directory |
  Sort-Object Name | Select-Object -Last 1
"Dossier Analyzers : $($alExt.FullName)\bin\Analyzers"
# Copier le .dll téléchargé dans ce dossier
```

---

## 3. Claude Code

Installation via l'**installeur natif** Windows (méthode utilisée sur le poste de référence) :

```powershell
irm https://claude.ai/install.ps1 | iex
```

> Alternative npm si l'installeur natif pose problème :
> `npm install -g @anthropic-ai/claude-code`

Fermer/rouvrir le terminal, puis vérifier :

```powershell
claude --version
```

### Authentification

```powershell
claude
```

Au premier lancement, Claude Code ouvre le navigateur pour se connecter
(compte Claude). Suivre l'invite. Une fois connecté, taper `/exit`.

---

## 4. Cloner le repo de configuration (le plugin)

Le plugin vit dans le repo `bc-claude-configs`. Le cloner à un emplacement stable
et **identique pour tous** (sinon le chemin du marketplace diffère, cf. §7).

```powershell
# Exemple : sous le dossier de travail AL
cd C:\Users\<toi>\Videos\AI
git clone <URL-du-repo-bc-claude-configs> bc-claude-configs
```

> Remplacer `<URL-du-repo>` par l'URL Azure DevOps / GitHub interne.
> Noter le **chemin absolu** du clone — il sera réutilisé en §7.

Synchronisation ultérieure des mises à jour de config :

```powershell
cd <chemin>\bc-claude-configs
git pull
```

---

## 5. Outils .NET (dotnet tools)

Trois outils .NET s'installent en une commande chacun. Le `--global` les ajoute
automatiquement au PATH (`%USERPROFILE%\.dotnet\tools`).

```powershell
dotnet tool install --global alcops.mcp            # serveur MCP alcops
dotnet tool install --global MSDyn365BC.AL.Runner  # al-runner : tests unitaires (sans BC ni Docker)
dotnet tool install --global MSDyn365BC.AL.Mutate  # al-mutate : mutation testing (utilise al-runner)
```

> `al-runner` et `al-mutate` ne requièrent **aucune instance BC ni Docker** : ils
> transpilent l'AL en C# et exécutent les tests en mémoire. Au 1er run, le compilateur
> AL (~57 Mo) et les DLL BC (~11 Mo) sont téléchargés puis mis en cache.
> `MSDyn365BC.AL.Mutate` cible **.NET 8** — garder le runtime .NET 8 présent.

Vérification :

```powershell
dotnet tool list --global    # doit lister alcops.mcp, MSDyn365BC.AL.Runner, MSDyn365BC.AL.Mutate
Get-Command alcops-mcp, al-runner, al-mutate
```

> Si une commande est « introuvable », ajouter `%USERPROFILE%\.dotnet\tools` au PATH
> utilisateur (voir §6 pour la méthode), puis rouvrir le terminal.

Les MCP `microsoft_docs_mcp`, `al-mcp-server`, `bc-code-intelligence-mcp` ne
nécessitent **aucune installation** : ils sont tirés via HTTP ou `npx` au premier
usage (d'où la dépendance Node de la §1).

➡️ Avec ces deux tools, les skills **`/run-tests`** (tests unitaires) et
**`/al-mutate`** sont pleinement fonctionnels sur Windows, sans Docker.

---

## 6. `al-compile` (StefanMaron/al-smart-compile)

Wrapper intelligent du compilateur AL. Installation via le repo public :

```powershell
git clone https://github.com/StefanMaron/al-smart-compile.git
cd al-smart-compile
.\install.ps1
```

L'installeur copie `al-compile.ps1` dans `%USERPROFILE%\.local\bin` et ajoute ce
dossier au PATH utilisateur. **Rouvrir le terminal**, puis vérifier :

```powershell
Get-Command al-compile
al-compile -Version
```

> Installation manuelle (si `install.ps1` échoue) :
> ```powershell
> $installDir = "$env:USERPROFILE\.local\bin"
> New-Item -ItemType Directory -Force -Path $installDir
> Copy-Item al-compile.ps1 $installDir\
> $p = [Environment]::GetEnvironmentVariable("Path","User")
> if ($p -notlike "*$installDir*") {
>   [Environment]::SetEnvironmentVariable("Path","$p;$installDir","User")
> }
> ```

---

## 7. Activer le plugin dans un projet AL

Le plugin s'active **par projet** via `.claude/settings.json` à la racine du projet AL.

```powershell
# Depuis la racine du projet AL
New-Item -ItemType Directory -Force -Path .claude
```

Créer `.claude\settings.json` avec ce contenu (adapter le **chemin** au clone de la §4) :

```json
{
  "extraKnownMarketplaces": {
    "local": {
      "source": {
        "source": "directory",
        "path": "C:/Users/<toi>/Videos/AI/bc-claude-configs"
      }
    }
  },
  "enabledPlugins": {
    "profile-al-development@local": true
  }
}
```

> ⚠️ Le `path` doit être le **chemin absolu** du clone, en slashs `/`.
> C'est pourquoi il vaut mieux que tout le monde clone au même endroit (§4).

---

## 8. Vérification finale (checklist)

Dans le dossier d'un projet AL (avec `app.json`), lancer `claude` puis :

```
/config
```

→ doit afficher le plugin **`profile-al-development`** comme chargé, et les
serveurs MCP connectés.

Checklist terminal :

```powershell
node -v                       # Node présent
git --version                 # Git présent
dotnet --version              # .NET présent
claude --version              # Claude Code présent
Get-Command al-compile        # wrapper de compilation
Get-Command alcops-mcp, al-runner, al-mutate  # MCP alcops + tests + mutation
Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Filter "ms-dynamics-smb.al-*" -Directory  # extension AL
```

Test de compilation de bout en bout (dans un projet AL, symboles téléchargés via
*AL: Download Symbols* dans VS Code) :

```powershell
al-compile
```

---

## 9. Tests d'intégration BC — `bc-publish` / `bc-test` (OPTIONNEL, Docker)

Les tests **unitaires** (`/run-tests`) et le **mutation testing** (`/al-mutate`)
fonctionnent déjà sans rien de plus (§5). Cette section ne concerne que les tests
d'**intégration** contre une vraie instance BC (pages, reports, events, flux UI),
exposés par les skills `/publish` et `bc-test`.

Ces deux CLI (`bc-publish`, `bc-test`) proviennent du repo communautaire
**bc-linux** et tournent contre une instance BC en **conteneur Docker** :

```powershell
# Prérequis : Docker Desktop installé et démarré
git clone https://github.com/StefanMaron/bc-linux.git
cd bc-linux
docker compose up -d --wait    # démarre l'instance BC locale
```

- Le conteneur expose `bc-publish` / `bc-test` et le script `run-tests.sh`.
- Configuration serveur via `.bcconfig.json` (créé avec `bc-publish --init`) ou
  la variable `$BC_SERVER` auto-détectée.

➡️ **À déployer uniquement chez les collègues qui ont besoin de tests
d'intégration.** Pour le quotidien (dev, revue, tests de logique), les §1–8
suffisent. Vérifier l'URL exacte du repo bc-linux côté DynInter avant diffusion.

---

## 10. Premiers pas

Une fois l'installation validée, dans un projet AL :

```
/init-context          # setup unique du contexte projet (accélère les workflows)
/fix "..."             # correctif rapide
/plan "..."            # conception de solution (architectes en débat)
/develop               # implémentation parallèle + revue 4 spécialistes
/compile               # compilation via al-compile
```

Routage par complexité (rappel) :

| Complexité | Critère | Route |
|------------|---------|-------|
| TRIVIAL | 1 fichier, fix évident | `/fix` |
| SIMPLE | 2-3 fichiers | `/fix` ou `/plan` → `/develop` |
| MEDIUM | 4-8 fichiers, décisions de design | `/plan` → `/develop` |
| COMPLEX | 9+ fichiers, nouvelle architecture | `/interview` → `/plan` → `/develop` → `/test` |

---

## Dépannage rapide

| Symptôme | Cause probable | Correctif |
|----------|----------------|-----------|
| `al-compile` introuvable | PATH non rafraîchi | rouvrir le terminal |
| Extension AL not found | extension VS Code absente | §2 |
| Plugin non chargé (`/config`) | chemin du marketplace faux | vérifier le `path` absolu en §7 |
| MCP non connectés | Node absent / proxy npx | vérifier `npx -v`, réseau |
| `alcops-mcp` introuvable | `~\.dotnet\tools` pas sur PATH | l'ajouter au PATH utilisateur |
| `.alpackages` manquant | symboles non téléchargés | *AL: Download Symbols* dans VS Code |
