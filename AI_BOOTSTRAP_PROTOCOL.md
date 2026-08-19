# 🧬 AI BOOTSTRAP PROTOCOL (HermetiCore MASTER SPEC)
## The Two-Tier Hermetic Separation Standard

> **MANDATORY AI DIRECTIVE:** Any AI agent (Antigravity, Claude, Copilot, Gemini) operating inside `HermetiCore` MUST read this file FIRST before taking any action. All rules below are non-negotiable.

---

## ⚡ 0. กฎเหล็กการตัดขาดจาก Host (Cold-Boot & Host Detachment Axiom)

> **MANDATORY HOST DETACHMENT DIRECTIVE:**
> 1. **Zero-Trust Host Environment:** ไม่ว่า Host Machine จะมี Git, Node.js หรือ Python ติดตั้งอยู่ในระบบหรือไม่ก็ตาม **AI Agent ถูกสั่งห้ามใช้ Global Binary ของเครื่องเด็ดขาด**
> 2. **Tier 1 Portable Primacy:** AI จะต้องดำเนินการติดตั้งและเรียกใช้ชุดคำสั่งผ่าน **Tier 1 Portable Toolchain** (`tools/git/cmd/git.exe`, `tools/node/node.exe`, `tools/python/python.exe`) ภายในโฟลเดอร์ `HermetiCore` เท่านั้น
> 3. **Session Path Shadowing:** ก่อนรันคำสั่งใดๆ AI ต้องตรวจสอบหรือทำการ Shadow PATH ใน Session เสมอ:
>    ```powershell
>    $env:PATH = "$PSScriptRoot\tools\git\cmd;$PSScriptRoot\tools\node;$PSScriptRoot\tools\python312;$env:PATH"
>    ```
> 4. **Self-Hydration Trigger:** หากพบว่าโฟลเดอร์ `tools/` ยังว่างเปล่า ให้เรียกใช้งาน `setup.ps1` ทันทีเพื่อดึง Portable Tools ทั้งหมดมาใส่ใน Tier 1 ก่อนเริ่มงาน

---

## 🏛️ 1. กฎเหล็กการแบ่งแยก 2 ชั้น (The Two-Tier Architecture Axiom)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  TIER 1: AI CONTROL PLANE (Root tools/ & .mcp/ - สำหรับ AI เท่านั้น)         │
│                                                                             │
│  • ความเป็นเจ้าของ: เป็นพื้นที่และเครื่องมือเฉพาะของ AI Agent               │
│  • สิ่งที่บรรจุ: 7z, Aria2, Git, Node LTS, Python 3.12, MCP Hub             │
│    (Neo4j, Redis, Postgres, SQLite, Playwright Browser, PyWin32)            │
│  • หน้าที่: ใช้เฉพาะช่วง "ต้นน้ำ" (Drafting, สกัด Requirement, Scaffold)   │
│  • ⛔ กฎเหล็กข้อห้าม: ห้าม AI สั่ง npm install หรือ pip install แพ็กเกจของ    │
│    โปรเจกต์ลงใน Tier 1 Root เด็ดขาด!                                        │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ (AI ทำหน้าที่เป็นผู้สร้างและวางสเปก)
┌──────────────────────────────────────▼──────────────────────────────────────┐
│  TIER 2: PROJECT DATA PLANE (projects/<name>/runtime/ - สำหรับโปรเจกต์)      │
│                                                                             │
│  • ความเป็นเจ้าของ: เป็นพื้นที่รันไทม์เฉพาะของแต่ละโปรเจกต์                 │
│  • สิ่งที่บรรจุ: Node.js, Python, node_modules, .venv, CUDA DLLs ประจำงาน   │
│  • มาตรฐาน Python ยุคใหม่: ใช้ pyproject.toml (PEP 621) ห้ามใช้ text ล้วน    │
│  • หน้าที่: ทุกคำสั่ง `npm install`, `pip install`, `npm run dev`, `build`   │
│    จะต้องรันผ่าน Runtime ภายในโฟลเดอร์ `projects/<name>/runtime/` เท่านั้น    │
│  • 🔒 การแยกส่วน: โปรเจกต์ A และ B มี Runtime อิสระต่อกัน 100%             │
│    ไม่มีการแชร์ node_modules ข้ามโปรเจกต์ และไม่ย้อนกลับไปกวน Tier 1 Base   │
└─────────────────────────────────────────────────────────────────────────────┘
```

> **🚨 MANDATORY SCAFFOLDING PROTOCOL (กฎการสร้างโปรเจกต์ใหม่):**
> หากผู้ใช้สั่งให้สร้างโปรเจกต์ใหม่ (เช่น "สร้างโปรเจกต์ Next.js" หรือ "สร้างโปรเจกต์ React"):
> 1. **ห้ามรัน `npx create-...` จาก Global หรือจาก Tier 1 โดยตรงเด็ดขาด!**
> 2. AI ต้องสร้างโฟลเดอร์ `projects/<name>/runtime/` ขึ้นมาก่อน
> 3. AI ต้องทำการก๊อปปี้ หรือสร้างสภาพแวดล้อม (Node.js/Python) ของ Tier 1 มาใส่ใน `runtime/` (สร้าง Tier 2 ให้เสร็จก่อน)
> 4. จากนั้นให้รันคำสั่งทั้งหมด (รวมถึง npx/npm) **ผ่าน Binary ที่อยู่ภายในโฟลเดอร์ runtime ของโปรเจกต์นั้นเท่านั้น**
> 5. หากละเมิดกฎนี้ โค้ดจะถูกสร้างนอกสภาพแวดล้อมจำลอง (Sandbox Bleed) ซึ่งถือเป็นความล้มเหลวร้ายแรง!

---

## 🤖 2. กฎเหล็ก Model-Stamped Git Commit (บังคับทุก AI ทุกโมเดล)

> **MANDATORY COMMIT IDENTITY RULE:** ทุก AI Agent ที่ commit code ลง repository นี้ **ต้องระบุชื่อโมเดล AI ของตัวเองอย่างชัดเจน** ทั้งใน `git config user.name` และในหัว commit message เสมอ

### 📐 รูปแบบ Commit มาตรฐาน

```bash
# Step 1: ตั้งค่า identity ให้ตรงกับโมเดลที่กำลังใช้งาน
git config user.name  "<AI Model Name>"
git config user.email "ai-<model-slug>@metabase.local"

# Step 2: Commit พร้อม Model Tag ในหัว message เสมอ
git commit -m "[AI: <Model Name>] <type>(<scope>): <description>"
```

### 🏷️ ตัวอย่าง Format ตามโมเดล

| โมเดลที่ใช้ | `user.name` | `user.email` | Prefix ใน message |
|---|---|---|---|
| Claude Sonnet 4.6 (Thinking) | `Claude Sonnet 4.6` | `ai-claude-s4@metabase.local` | `[AI: Claude Sonnet 4.6 (Thinking)]` |
| Claude Opus 4 | `Claude Opus 4` | `ai-claude-opus4@metabase.local` | `[AI: Claude Opus 4]` |
| Gemini 3.7 Flash | `Gemini 3.7 Flash` | `ai-gemini-37f@metabase.local` | `[AI: Gemini 3.7 Flash]` |
| Gemini 3.1 Pro | `Gemini 3.1 Pro` | `ai-gemini-31p@metabase.local` | `[AI: Gemini 3.1 Pro]` |
| GitHub Copilot | `GitHub Copilot` | `ai-copilot@metabase.local` | `[AI: GitHub Copilot]` |

### ✅ ตัวอย่าง Commit ที่ถูกต้อง

```bash
[AI: Claude Sonnet 4.6 (Thinking)] fix(arch): auto-delete root temp/, move lockfile to .setup-lock
[AI: Gemini 3.7 Flash] feat(mcp): add Neo4j and Redis to MCP fleet
[AI: Claude Opus 4] refactor(services): migrate api-backend to pyproject.toml PEP 621
```

### ❌ Commit ที่ไม่ได้รับอนุญาต (REJECTED)

```bash
fix: some changes           ← ไม่มี [AI: ...] prefix
Gemini AI: update stuff     ← ไม่ตรง format
feat: add feature           ← ไม่ระบุโมเดล
```

### 🎯 ประโยชน์ของระบบนี้

1. **Blame by Model:** `git log --grep="Claude Sonnet"` → เห็นทันทีว่าโมเดลไหนแก้อะไร
2. **Bug Attribution:** ถ้าโค้ดพัง ดู commit tag รู้ทันทีว่าโมเดลไหนก่อปัญหา
3. **Model Capability Audit:** ถ้าสลับโมเดลแล้วแก้ผ่าน → รู้ว่าปัญหานี้ต้องใช้โมเดลไหน
4. **Multi-Agent History:** ถ้าทำงานหลายโมเดลพร้อมกัน ประวัติไม่ปน

---

## 🎯 3. เสาหลัก 3 เฟรมเวิร์ก (The 3 Framework Pillars)

1. **PowerShell Engine (Windows Automation Backbone):**
   - รองรับทั้ง **PowerShell 5.1 (Desktop)** ในตัว Windows และ **PowerShell 7.x (Core)**
   - ทำงานแบบ Bare-Metal Zero-Admin Scripting

2. **Node.js LTS Engine (Web & MCP Ecosystem):**
   - พัฒนาเว็บด้วย Next.js, React, Tailwind, TypeScript
   - รัน MCP Servers และเชื่อมต่อ OmniProxy LAN Cache อัตโนมัติ

3. **Modern Python 3.12 Engine (AI & Data Science):**
   - บังคับใช้มาตรฐาน **`pyproject.toml` (PEP 517/518/621)** เสมอ (เทียบเท่า `package.json` ของ Node)
   - รองรับ PyTorch, CUDA Dynamic DLLs, FastAPI, และ ComfyUI

---

## 🧪 4. กฎเหล็ก Sandbox & Demo User Management

> **MANDATORY SANDBOX RULE:** `sandbox/` ภายใน Project Pod คือ ephemeral test zone ที่มีกฎการจัดการที่ชัดเจน

### 📁 โครงสร้าง Sandbox ที่ถูกต้อง

```text
projects/<name>/sandbox/
├── demo_users/          # Playwright isolated userDataDir — ข้ามเซสชันได้, คงค่าข้ามวัน
│   ├── user_alice/      # Cookie, LocalStorage, IndexedDB ของ Alice
│   └── user_bob/        # Cookie, LocalStorage, IndexedDB ของ Bob
├── mock_data/           # Static seed data — ✅ committed to git
│   ├── seed_users.json
│   └── seed_chat_rooms.json
└── temp/                # Runtime trash — ❌ gitignored, ลบเมื่อเริ่ม test run ใหม่
```

### 🔒 กฎการจัดการ Sandbox

| โฟลเดอร์ | ลบเมื่อ Reboot? | ลบเมื่อ? | Committed to Git? |
|---|---|---|---|
| `demo_users/` | ❌ **ห้ามลบ** | เมื่อ AI หรือ User สั่งลบเท่านั้น | ❌ (gitignored profiles) |
| `mock_data/` | ❌ ห้ามลบ | ไม่มีวันลบ — เป็น canonical seed | ✅ committed |
| `temp/` | ❌ ไม่ลบอัตโนมัติตอน reboot | ลบตอนเริ่ม test run ใหม่เท่านั้น | ❌ gitignored |

### ⛔ สิ่งที่ห้ามทำ

- ❌ ห้าม symlink `sandbox/temp/` → `%TEMP%` (ข้อมูลหายเมื่อ reboot ระหว่างพัฒนา)
- ❌ ห้ามลบ `demo_users/` อัตโนมัติโดยไม่มีคำสั่งจาก Human หรือ AI ที่ได้รับอนุมัติ
- ✅ ลบ `temp/` ได้ตอนเริ่ม test run ใหม่ (ไม่ใช่ตอน shutdown)

---

## 📋 5. วงจรการทำงานของ AI (Lifecycle Operational Rules)

### 🔹 สเต็ปที่ 1: ช่วงตั้งต้น / ร่างไอเดีย (Drafting Phase)
- AI สามารถใช้เครื่องมือใน **Tier 1 (`tools/`)** และ MCP ต่างๆ ในการค้นหาข้อมูล, ร่างข้อกำหนดใน `specs/01_REQUIREMENTS.md`, และดึง Design Tokens จาก Figma มาใส่ใน `design/`

### 🔹 สเต็ปที่ 2: ช่วงขึ้นโครงสร้างและติดตั้งโค้ด (Construction Phase)
- เมื่อเริ่มพัฒนาโค้ดหรือติดตั้ง Dependencies (เช่น `npm install` หรือ `pip install`):
  - **AI จะต้องสั่งงานผ่าน Runtime ในโฟลเดอร์ของโปรเจกต์นั้นเสมอ (`projects/<name>/runtime/`)**
  - หากโปรเจกต์ใช้ Node.js: ให้โหลด Node.js พกพามาใส่ใน `projects/<name>/runtime/tools/node/`
  - หากโปรเจกต์ใช้ Python + GPU: ให้โหลด Python + CUDA DLLs มาใส่ใน `projects/<name>/runtime/tools/nvidia/`

### 🔹 สเต็ปที่ 3: ช่วงทดสอบและส่งมอบงาน (Verification & Gate Phase)
- AI ทดสอบความถูกต้องใน `staging/ai/` โดยรันผ่าน Runtime เฉพาะของโปรเจกต์
- ส่งต่อให้คนทดสอบใน `staging/human/` ผ่านไฟล์ `start_verify.bat`
- ซิงค์โค้ดที่ผ่านการอนุมัติเข้า `repo/` เพื่อทำ Git Push

---

## 📜 6. ข้อกำหนดการบันทึก Audit Log (Continuous Logging Policy)

> **UPDATED POLICY:** โฟลเดอร์ `logs/` ถูกตั้งค่าเป็น **gitignored** (local-only) — ไม่มีการ commit log files ขึ้น GitHub อีกต่อไป
> ไฟล์ log ต่างๆ ยังสามารถใช้งานได้บน local machine แต่จะไม่ถูก push ขึ้น repository

สำหรับ AI Agent ที่ต้องการบันทึก session state:
1. เขียน log ลงโฟลเดอร์ `logs/` ได้ตามปกติ (local-only, gitignored)
2. **ห้าม** สร้างไฟล์ log ใน root หรือ config/ โดยตรง
3. สำหรับ session handover ระหว่าง AI agents ให้ใช้ git commit message แทน log files

Format commit สำหรับ AI-to-AI handover:
```markdown
[AI: <Model Name>] handover(<scope>): <summary of state and next steps>
```

---

## 🛡️ 7. การันตีความปลอดภัย (Zero Contamination Guarantee)

1. **Tier 1 Root Base** จะสะอาดและไม่เปลี่ยนสภาพตลอดไป (Immutable AI Workstation)
2. **Tier 2 Projects** สามารถลบทิ้ง แตกไฟล์ใหม่ หรือย้ายไปเครื่องอื่นได้ทันทีโดยไม่พัง
3. **Root `temp/`** คือ Transient Staging เท่านั้น — ถูกลบอัตโนมัติหลัง `setup.ps1` เสร็จ
4. **`sandbox/demo_users/`** คงค่าข้ามวัน ข้าม session ข้าม reboot — ลบได้เฉพาะเมื่อ Human/AI สั่ง Explicit เท่านั้น

---

## 🔑 8. กฎการเข้าถึงความลับและ Credentials (Zero-Leak Ingestion Axiom)

> **MANDATORY CREDENTIAL DIRECTIVE:**
> 1. **Hydration First:** ก่อนที่ AI จะเรียกใช้ GitHub MCP Server หรือ API Tools ต้องตรวจสอบว่ามี `config/.env` หรือไม่ หากยังไม่มีให้แนะนำผู้ใช้หรือคัดลอกจาก `config/env.example`
> 2. **Token Ingestion:** AI จะอ่าน `GITHUB_PERSONAL_ACCESS_TOKEN` จาก `config/.env` หรือ Environment Variables เท่านั้น **ห้าม Hardcode Token ลงในซอร์สโค้ดหรือ Commit Message เด็ดขาด**
> 3. **Device-Bound Isolation:** เครื่อง MainPC และ Laptop ต้องใช้ Token และ SSH Key แยกกัน (`HermetiCore-MainPC` vs `HermetiCore-Laptop`) ห้ามซิงค์ความลับข้ามเครื่อง per ISO/IEC/IEEE 12207
> 4. **Git Operations:** การ Push โค้ดผ่าน Git CLI จะใช้กุญแจ `config/id_ed25519` เพื่อความปลอดภัยสูงสุดแบบ Zero-Prompt (ดูคู่มือฉบับเต็มที่ [`config/README.md`](config/README.md))

