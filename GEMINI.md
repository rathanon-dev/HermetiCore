# HermetiCore — AI Agent Rules (GEMINI.md)

> **⚠️ MANDATORY: Read [`AI_BOOTSTRAP_PROTOCOL.md`](AI_BOOTSTRAP_PROTOCOL.md) FIRST.**
> That file is the master spec covering Tier architecture, sandbox rules, credentials, and commit identity.
> This file (`GEMINI.md`) is loaded automatically by Antigravity AI and covers the **operational enforcement rules** not yet in the master spec.

---

## 🔴 CRITICAL: Download Policy — NO Invoke-WebRequest for Binaries

**FORBIDDEN — Never use these for downloading binary files or packages:**
```powershell
# BANNED — use aria2c instead
Invoke-WebRequest -Uri <url> -OutFile <file>
Invoke-RestMethod -Uri <url>
curl.exe   # Windows built-in, single-threaded
wget
```

**REQUIRED — Always use Tier 1 tools for all downloads:**
```powershell
# CORRECT: 8-connection parallel download via Tier 1 aria2c
$aria2 = ".\tools\aria2\aria2c.exe"
& $aria2 -x 8 -s 8 -d $outputDir -o $filename $url

# EXCEPTION: Only the 7-zip bootstrap step in setup.ps1 may use
# Invoke-WebRequest, because aria2c does not yet exist at that point.
# This is the ONE AND ONLY permitted exception — document it if used.
```

---

## 🔴 CRITICAL: Runtime Isolation — Use Tier 2 Scaffolders

**FORBIDDEN — Never install runtimes globally or write your own download scripts:**
```powershell
# BANNED
choco install nodejs
winget install python
pip install <package>          # Only allowed INSIDE a project runtime
npm install -g <package>       # Only allowed inside project runtime
```

**REQUIRED — Always use the Tier 2 scaffolders:**
```powershell
# CORRECT: Deploy isolated Node.js runtime to a project
& ".\.skills\hermeticore-runtimes\Runtime-Node.ps1" `
    -TargetProjectName "my-app" -NodeVersion "20.17.0"

# CORRECT: Deploy isolated Python runtime (optionally with packages)
& ".\.skills\hermeticore-runtimes\Runtime-Python.ps1" `
    -TargetProjectName "my-api" -PythonVersion "3.12.5" `
    -InstallPackages "fastapi uvicorn"

# CORRECT: Deploy isolated Python + CUDA runtime
& ".\.skills\hermeticore-runtimes\Runtime-Python-CUDA.ps1" `
    -TargetProjectName "my-ai-app" -PythonVersion "3.12.5" -CudaVersion "12.1.1"
```

**Result paths after scaffolding:**
- Node: `projects/<name>/runtime/tools/node/node.exe`
- Python: `projects/<name>/runtime/tools/python/python.exe`
- CUDA DLLs: `projects/<name>/runtime/tools/nvidia/bin/*.dll`

---

## 🔴 CRITICAL: Git Commit Identity — Model Stamping Required

Every AI commit **MUST** include the model name. See full spec in [`AI_BOOTSTRAP_PROTOCOL.md §2`](AI_BOOTSTRAP_PROTOCOL.md).

**Quick reference — always run before committing:**
```powershell
$git = ".\tools\git\cmd\git.exe"
& $git config user.name  "Claude Sonnet 4.6"          # ← change to your model
& $git config user.email "ai-claude-s4@metabase.local"
& $git commit -m "[AI: Claude Sonnet 4.6 (Thinking)] fix(scope): description"
```

**Format:** `[AI: <Exact Model Name>] <type>(<scope>): <description>`

Examples:
- `[AI: Claude Sonnet 4.6 (Thinking)] fix(ci): bootstrap pip after NuGet install`
- `[AI: Gemini 3.1 Pro] feat(mcp): add Neo4j server`

**REJECTED (CI will flag these):**
- `fix: some changes` ← no [AI:] prefix
- `feat: add stuff` ← no model identity

---

## 🟡 WARNING: Project Structure — Preserve Template

```powershell
# BANNED — destroys the blueprint
Remove-Item projects\* -Recurse

# CORRECT — delete specific project only
Remove-Item projects\my-old-app -Recurse -Force
# Template at projects\_template_fullstack MUST always be preserved
```

---

## 🟡 WARNING: Git Push — Never Commit Sensitive Data

Gitignored files — **NEVER** commit these:
- `config/.env` — local secrets and proxy URLs
- `config/id_ed25519*` — SSH private keys
- `SESSION_HANDOVER_LOG.md` — local AI session state
- `dump.txt` — debug dumps
- `tools/` — downloaded binaries (auto-restored by setup.ps1)
- `projects/*/runtime/` — language runtimes (auto-restored by Tier 2 scaffolders)
- `logs/` — local-only audit logs (gitignored entirely)

Before any push:
```powershell
& ".\tools\git\cmd\git.exe" status
# Verify no sensitive files appear in the staged list
```

---

## 🟢 Tier Architecture Quick Reference

| Tier | Scope | Location | Purpose |
|------|-------|----------|---------|
| **Tier 1** | Shared toolchain | `tools/` | 7zip, aria2c, git, node, python (base) |
| **Tier 2** | Per-project isolation | `projects/<name>/runtime/tools/` | Sandboxed runtimes per project |

**All Tier 2 scripts:** `.skills/hermeticore-runtimes/`
**Full architecture:** [`AI_BOOTSTRAP_PROTOCOL.md`](AI_BOOTSTRAP_PROTOCOL.md) | [`doc/th/02_TWO_TIER_RULES.md`](doc/th/02_TWO_TIER_RULES.md)

---

## Proxy Configuration

- URL read from `config/.env` → `OMNIPROXY_URL`
- Scripts auto-detect proxy via 1.2-second TCP handshake
- Falls back to direct internet if offline
- Never hardcode proxy credentials in source files
