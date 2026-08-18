<a id="top"></a>

# 🎭 มาตรฐานสถาปัตยกรรม Playwright Browser MCP Engine
[⬅️ กลับสู่หน้าหลัก (Back to README)](../../README.md) | [🇬🇧 Read in English](../en/03_PLAYWRIGHT_MCP_SPEC.md)

---

## 📌 บทนำ: ทำไม MetaBase-AI จึง "บังคับใช้ Playwright เท่านั้น"

ในการพัฒนา AI Workstation ยุคใหม่ AI Agent จำเป็นต้องมี **"ดวงตาและมือ"** สำหรับการทดสอบ Web UI, รัน E2E Testing, ตรวจสอบ Visual Regression, และทำ Web Scraping ความเร็วสูง

จากผลการวิจัยและบทความเปรียบเทียบมาตรฐานระดับโลกของ **Autify ([Playwright vs Puppeteer: What's the Difference?](https://autify.com/blog/playwright-vs-puppeteer))** ทีมผู้สร้างแกนหลักของ Puppeteer ที่ Google ได้ย้ายมาร่วมกับ Microsoft เพื่อสร้าง **Playwright (2020)** โดยแก้ไขจุดบกพร่องเชิงสถาปัตยกรรมทั้งหมดของ Puppeteer

---

## 🥊 ตารางเปรียบเทียบเชิงวิศวกรรม: Playwright vs Puppeteer สำหรับ AI Agents

| คุณสมบัติ (Feature) | 🎭 Microsoft Playwright *(บังคับใช้)* | 🐕 Google Puppeteer *(เลิกใช้)* | ผลกระทบต่อ AI Agent |
|---|---|---|---|
| **Auto-Waiting (รอ DOM อัตโนมัติ)** | ✅ **มีในตัว 100%** (รอปุ่มคลิกได้, รอ element โหลดเสร็จอัตโนมัติ) | ❌ ต้องเขียน `waitForSelector()` หรือสั่ง Sleep เอง | ลดปัญหา AI คลิกพลาดเพราะหน้าเว็บโหลดช้า (Anti-Flaky Tests) |
| **Multi-Context Sandbox** | ✅ `browser.newContext()` สร้าง Session แยก Cookie/Storage ใน **< 5ms** | ⚠️ ต้องเปิด Browser Instance ใหม่ (ช้าและกิน RAM สูง) | จำลอง User หลายคน (เช่น LAN Share Chat) โดย Cookie ไม่ตีกัน |
| **Browser Engine Support** | ✅ **Chromium, Firefox, WebKit (Safari)** | ⚠️ เน้นเฉพาะ Chromium (Firefox เป็น Experimental) | ทดสอบความเข้ากันได้ข้ามเบราว์เซอร์ได้สมบูรณ์ |
| **Network Mocking & Proxy** | ✅ ดักจับ Route, Mock API Response, และสลับ Proxy ราย Context ได้ | ⚠️ จำกัดเฉพาะระดับ Browser Process ทั้งตัว | จำลองการต่อเน็ตผ่าน OmniProxy LAN (`192.168.1.10:8080`) ได้อิสระ |
| **Multi-Language SDK** | ✅ TypeScript/Node.js, Python, C#, Java | ❌ JavaScript/Node.js เป็นหลัก (Python เป็น unofficial) | รองรับทั้งเสาหลัก Node.js และ Python ของ MetaBase-AI |
| **Anti-Bot & Human Emulation** | ✅ จำลองการเคลื่อนไหวเมาส์, การพิมพ์, และ Event เสมือนมนุษย์ | ⚠️ ตรวจจับบอทได้ง่ายกว่าเนื่องจากยึด CDP เดิม | ลดโอกาสถูกบล็อกเมื่อ AI ดึงข้อมูลหรือเทสต์เว็บ |

---

## 🏛️ สถาปัตยกรรม Zero-Pollution Playwright MCP ใน MetaBase-AI

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ 🧠 AI AGENT (Antigravity / Claude / Copilot)                                │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ (JSON-RPC Protocol)
┌──────────────────────────────────────▼──────────────────────────────────────┐
│ 🔌 TIER 1: Playwright MCP Server (@executeautomation/playwright-mcp-server) │
├─────────────────────────────────────────────────────────────────────────────┤
│ • Execution Mode: Headless Sandbox (ไม่รบกวนหน้าจอผู้ใช้)                    │
│ • Isolated Browser Storage: tools/playwright-browsers/ (ไม่แตะเครื่อง User) │
│ • Network Proxy Routing: รองรับ LAN OmniProxy 192.168.1.10:8080             │
│ • Toolset Exposed to AI:                                                    │
│   ├── playwright_navigate (เปิด URL / Localhost)                            │
│   ├── playwright_screenshot (แคปภาพส่งให้ AI วิเคราะห์ UI)                 │
│   ├── playwright_click / fill (กรอกฟอร์ม / กดปุ่ม)                          │
│   ├── playwright_evaluate (รัน JavaScript สกัด DOM)                         │
│   └── playwright_get_console_logs (ดักจับ Error ในหน้าเว็บ)                 │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ (Automated Verification)
┌──────────────────────────────────────▼──────────────────────────────────────┐
│ 🌐 TIER 2: Project Runtime Web Services (Next.js :3000 / FastAPI :8000)     │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔒 กฎเหล็กความปลอดภัยของเบราว์เซอร์ (Strict Isolation Rules)

1. **ห้ามแตะเบราว์เซอร์ส่วนตัวของ User:** Playwright จะถูกสั่งให้เก็บไดรเวอร์และโปรไฟล์ไว้ใน `tools/playwright-browsers/` และ `temp/` ภายใน MetaBase-AI เท่านั้น
2. **ห้ามแชร์ Cookie ระหว่างการทดสอบ:** ทุกการทดสอบจะต้องรันภายใต้ `BrowserContext` ใหม่เสมอ เพื่อป้องกันปัญหา Session ตีกัน
3. **รองรับ OmniProxy LAN Caching:** เมื่อตรวจพบ LAN Gateway (`192.168.1.10:8080`) ทราฟฟิกจะถูกส่งผ่านแคชความเร็วสูงเพื่อประหยัดแบนด์วิดท์

---

---

**การนำทาง:** [🏠 หน้าหลัก](../../README.md) | [🇹🇭 ภาษาไทย](../../README.th.md) | [🇬🇧 English](../../README.en.md) | [🏛️ สถาปัตยกรรม](01_ARCHITECTURE.md) | [🔒 กฎ 2 ชั้น](02_TWO_TIER_RULES.md) | [⬆️ กลับด้านบน](#top)

**ผู้พัฒนาและดูแลโครงการ:** [@rathanon-dev](https://github.com/rathanon-dev) · **สัญญาอนุญาต:** [MIT](../../LICENSE) · [เครดิตทั้งหมด](../../README.md#-เครดิตและเครื่องมือที่อ้างอิง-credits--acknowledgements)
