<a id="top"></a>
[🏠 หน้าหลัก (Home)](../../README.md) > [📚 เอกสารภาษาไทย (TH)] > 📄 **กฎเหล็กการแยกขาด 2 ชั้น (Two-Tier Rules)**

# 🔒 กฎเหล็กการแยกขาด 2 ชั้น (Two-Tier Hermetic Separation & Scaffolding Protocols)

เอกสารฉบับนี้คือ **"สมองกล (Core Logic)"** ที่บังคับใช้กับ AI Agents ทุกตัว (เช่น Antigravity, Claude, Gemini) เพื่อให้การสร้างและรันโปรเจกต์เป็นไปตามมาตรฐานการแยกส่วนอย่างเด็ดขาด (Zero-Footprint).

---

## 🛑 PART 1: กฎการทำงานของ Tier 1 (AI Control Plane)
1. **จบที่ `setup.ps1`:** เมื่อระบบรัน `setup.ps1` เสร็จสิ้น โฟลเดอร์ `tools/` (Tier 1) ถือว่า **ถูกล็อค (Immutable)** ทันที
2. **ขอบเขตการใช้งาน:** AI ได้รับอนุญาตให้ใช้ Node.js และ Python จาก Tier 1 เพื่อรันสคริปต์เครื่องมือตัวเอง หรือเชื่อมต่อ MCP Servers เท่านั้น
3. **⛔ ข้อห้ามสูงสุด:** ห้าม AI สั่ง `npm install` หรือ `pip install` แพ็กเกจของ "ชิ้นงาน" ลงใน Tier 1 Root โดยเด็ดขาด 

---

## 🏗️ PART 2: กฎการสร้างรันไทม์ Tier 2 (Scaffolding Logic)
เมื่อ AI ได้รับคำสั่งสร้างโปรเจกต์ (เช่น "สร้าง Next.js" หรือ "รัน Python API") AI จะต้องเขียนและรันสคริปต์เพื่อ **"ติดตั้ง Runtime ขึ้นมาใหม่"** ในโฟลเดอร์ของโปรเจกต์นั้นๆ เสมอ โดยแบ่งตาม 3 เงื่อนไขดังนี้:

### 🟩 Condition 1: Node.js Project (เช่น Next.js, React)
*   **เป้าหมาย:** สร้างโปรเจกต์ Web / Frontend
*   **คำสั่งบังคับ (Logic):**
    1. สร้างโฟลเดอร์ `projects/<name>/runtime/tools/node/`
    2. เขียน PowerShell ไปโหลดไฟล์ `.zip` ของ Node.js รุ่นล่าสุดจาก `nodejs.org` แตกไฟล์ลงโฟลเดอร์นี้
    3. ล้างค่าเครื่อง (Sandboxing): `$env:PATH = "$pwd\projects\<name>\runtime\tools\node;$env:PATH"`
    4. รันคำสั่ง `npx create-...` ภายใต้ PATH ของ Tier 2 เท่านั้น

### 🟦 Condition 2.1: Python Project (Normal / Web API)
*   **เป้าหมาย:** สร้างโปรเจกต์ Python ธรรมดาที่ไม่ได้ใช้การ์ดจอ (เช่น FastAPI, Scripts)
*   **คำสั่งบังคับ (Logic):**
    1. สร้างโฟลเดอร์ `projects/<name>/runtime/tools/python/`
    2. ยิง API โหลด **Python Portable ผ่าน NuGet** (`api.nuget.org/.../python.3.12.5.nupkg`) (เพื่อให้มี `pip` แบบสมบูรณ์โดยไม่ต้องแฮ็ก `_pth`)
    3. แตกไฟล์ด้วย 7-Zip ลงโฟลเดอร์ Tier 2
    4. ตั้งค่า PATH ชี้ไปที่ Python ของ Tier 2 ก่อนทำการ `pip install`

### 🟪 Condition 2.2: Python Project + CUDA (AI / ML / ComfyUI)
*   **เป้าหมาย:** โปรเจกต์ที่ต้องการเร่งประมวลผลด้วย GPU
*   **คำสั่งบังคับ (Logic):**
    1. โหลดและสร้างรันไทม์แบบ **Condition 2.1** ก่อน (Python ผ่าน NuGet)
    2. **CUDA Zero-Footprint Injection:** เขียนสคริปต์ไปดึง NVIDIA Redist JSON (`developer.download.nvidia.com`)
    3. สกัดและโหลดเฉพาะไฟล์ `.dll` ที่จำเป็น (เช่น `cublas64_12.dll`, `cudnn64_8.dll`) นำมาใส่ใน `projects/<name>/runtime/tools/nvidia/bin/`
    4. ฉีดเข้า PATH: `$env:PATH = "$pwd\projects\<name>\runtime\tools\nvidia\bin;$env:PATH"` แล้วถึงรันสคริปต์ AI (ไม่ต้องลง Installer ของ NVIDIA ให้รกเครื่องหลัก)

---

## 🌐 PART 3: กฎการแสดงผลผ่านเบราว์เซอร์จำลอง (Browser Sandbox Execution)
เมื่อ AI ดำเนินการตาม **PART 2** จนเว็บเซิร์ฟเวอร์รันขึ้นมาแล้ว (เช่น รัน `npm run dev` ขึ้นที่ Port 3000) ห้าม AI จบงานแล้วทิ้งให้ User ไปเปิดเบราว์เซอร์เอาเอง!

*   **คำสั่งบังคับ:** AI ต้องใช้ **Playwright จาก Node.js ของ Tier 1** ทำการรันเบราว์เซอร์แบบแยกส่วน (Isolated Browser)
*   **โค้ดตัวอย่างที่ AI ต้องเรียกใช้:**
    ```powershell
    $playwrightNode = "..\..\..\tools\node\node.exe" # อ้างอิงจากโฟลเดอร์โปรเจกต์กลับไป Tier 1
    # สั่งเปิดหน้าต่าง Preview ทันที (Headless = false)
    & $playwrightNode -e "const { chromium } = require('playwright'); (async () => { const browser = await chromium.launch({ headless: false }); const page = await browser.newPage(); await page.goto('http://localhost:3000'); })();"
    ```
*   **ผลลัพธ์:** เบราว์เซอร์ Sandbox จะเด้งขึ้นมาตรงหน้า User เพื่อให้ทดสอบเว็บในสภาพแวดล้อมจำลองทันที โดยไม่เก็บประวัติแคช (Cache/Cookies) ปนเปื้อนเบราว์เซอร์หลักของเครื่อง

---

**การนำทาง (Navigation):** [🏠 หน้าหลัก (Home)](../../README.md) | [🏛️ สถาปัตยกรรม (Architecture)](01_ARCHITECTURE.md) | [🔒 กฎ 2 ชั้น (Two-Tier Rules)](02_TWO_TIER_RULES.md) | [🎭 Playwright MCP](03_PLAYWRIGHT_MCP_SPEC.md) | [📜 ข้อกำหนด (Licenses)](04_TOOLING_AND_LICENSES.md) | [⬆️ กลับด้านบน (Top)](#top)

**ผู้พัฒนาและดูแลโครงการ:** [@rathanon-dev](https://github.com/rathanon-dev) · **สัญญาอนุญาต:** [MIT](../../LICENSE)
