---
name: local-bc
description: Manage a local Business Central instance for development and testing. Detects host vs container environment automatically. Uses bc-linux run-tests.sh for test execution.
---

# /local-bc — Local Business Central

A local BC instance for compiling, publishing, and running tests.

## Environment Detection

Check `$BC_SERVER` to determine how to reach BC:

| Environment | `$BC_SERVER` | BC address |
|-------------|-------------|------------|
| Host (direct) | unset | `localhost` |
| Sandboxed container | set (e.g. `172.17.0.1`) | `$BC_SERVER` |

**Inside a container:** You cannot start or stop BC — there is no Docker CLI or socket.
The user must start the BC stack on the host before you can use it. If BC is not
reachable, tell the user:

> BC is not running. Please start it on the host:
> ```
> cd ~/Documents/Repos/community/bc-linux && docker compose up -d --wait
> ```

## Check if BC is Running

```bash
BC_HOST="${BC_SERVER:-localhost}"
curl -sf -u BCRUNNER:Admin123! "http://${BC_HOST}:7049/BC/dev/metadata" > /dev/null 2>&1 \
  && echo "BC is running" || echo "BC is NOT running"
```

## BC Endpoints

| Service | URL | Auth |
|---------|-----|------|
| Dev (publish/symbols) | `http://${BC_HOST}:7049/BC/dev` | `BCRUNNER:Admin123!` |
| OData | `http://${BC_HOST}:7048/BC/ODataV4` | `BCRUNNER:Admin123!` |
| API | `http://${BC_HOST}:7052/BC/api` | `BCRUNNER:Admin123!` |
| Web Client / WebSocket | `http://${BC_HOST}:7085` | `BCRUNNER:Admin123!` |

## Publish

```bash
bc-publish    # Uses .bcconfig.json or $BC_SERVER automatically
```

Or with curl:
```bash
BC_HOST="${BC_SERVER:-localhost}"
curl -u BCRUNNER:Admin123! -X POST \
  -F "file=@path/to/app.app;type=application/octet-stream" \
  "http://${BC_HOST}:7049/BC/dev/apps?SchemaUpdateMode=forcesync"
```

Publish dependencies first, then the main app, then the test app.

## Run Tests

Tests use the `run-tests.sh` script from the bc-linux repo, mounted at `/opt/bc-linux`.

```bash
BC_HOST="${BC_SERVER:-localhost}"
/opt/bc-linux/scripts/run-tests.sh \
  --base-url "http://${BC_HOST}:7048/BC" \
  --dev-url "http://${BC_HOST}:7049/BC/dev" \
  --app path/to/test-app.app
```

**Options:**
- `--app <path>` — Test .app file (auto-published + codeunit IDs auto-discovered)
- `--codeunit-range <range>` — Codeunit ID range (e.g. `70000` or `70000..70001`)
- `--base-url <url>` — BC OData base (default: `http://localhost:7048/BC`)
- `--dev-url <url>` — BC Dev endpoint (default: `http://localhost:7049/BC/dev`)
- `--auth <user:pass>` — Credentials (default: `BCRUNNER:Admin123!`)
- `--timeout <minutes>` — Overall timeout (default: 30)

**What the script does:**
1. Publishes the TestRunnerExtension if needed
2. Publishes your test app (if `--app` given)
3. Discovers test codeunit IDs from the .app's SymbolReference.json
4. Sets up the test suite via OData API
5. Executes tests via WebSocket (TestPage session)
6. Reports results with exit code 0=pass, 1=failures

**If `/opt/bc-linux` is not mounted**, tell the user to add this volume to their
docker run command:
```
-v "$HOME/Documents/Repos/community/bc-linux:/opt/bc-linux:ro"
```

## Download Symbols

```bash
BC_HOST="${BC_SERVER:-localhost}"
mkdir -p .alpackages
for app in "System" "System Application" "Base Application" "Application"; do
  curl -sf -u BCRUNNER:Admin123! \
    "http://${BC_HOST}:7049/BC/dev/packages?publisher=Microsoft&appName=$(echo $app | sed 's/ /%20/g')&appVersion=0.0.0.0" \
    -o ".alpackages/${app}.app" && echo "Downloaded ${app}" || echo "Failed: ${app}"
done
```

## .bcconfig.json

Both `bc-publish` and `bc-test` auto-detect `$BC_SERVER` when no `.bcconfig.json`
exists. If a `.bcconfig.json` is present, its `server` field takes precedence.

```json
{
  "server": "http://localhost",
  "port": 7048,
  "instance": "BC",
  "authentication": "UserPassword",
  "username": "admin",
  "password": "Admin123!"
}
```

**Inside a container**, either omit `.bcconfig.json` (tools use `$BC_SERVER`
automatically) or set `"server"` to `"http://<BC_SERVER value>"`.

## Full Build-Test Cycle

1. Check if BC is running (curl dev endpoint), ask user to start if not
2. Download symbols to `.alpackages/`
3. Compile (`al-compile`)
4. Publish main app, then test app (`bc-publish` or curl)
5. Run tests (`/opt/bc-linux/scripts/run-tests.sh --app <test.app> --base-url ...`)

## Starting BC on the Host

The user runs this (you cannot run it from inside a container):

```bash
cd ~/Documents/Repos/community/bc-linux && docker compose up -d --wait
```

First boot takes 5-10 minutes (artifact download + DB restore). Subsequent starts ~20 seconds.

To set a specific version:
```bash
BC_VERSION=27.5 BC_COUNTRY=w1 docker compose up -d --wait
```

To stop:
```bash
docker compose down       # Keep data
docker compose down -v    # Full reset
```
