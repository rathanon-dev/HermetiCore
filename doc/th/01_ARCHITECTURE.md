<a id="top"></a>
[🏠 หน้าหลัก (Home)](../../README.md) > [📚 เอกสารภาษาไทย (TH)] > 📄 **สถาปัตยกรรมระบบ (Architecture)**

# 🏛️ สถาปัตยกรรมระบบ HermetiCore

---

## 1. ภาพรวมสถาปัตยกรรมแบบ 3 เลเยอร์
ระบบถูกออกแบบให้แบ่งแยกความรับผิดชอบอย่างชัดเจน:
- **Layer 1 (Meta-Framework Control Plane):** คุมเครื่องมือ AI, MCP และ Logging
- **Layer 2 (Network & Acceleration Bus):** เชื่อมต่อ OmniProxy LAN Caching
- **Layer 3 (Project Pods):** กักขังซอร์สโค้ดและรันไทม์ของแต่ละงานแบบ 100%

---

## 2. วงจรชีวิตต้นน้ำสู่ปลายน้ำ (End-to-End Lifecycle)
1. `specs/`: ข้อกำหนดสถาปัตยกรรมและ API Contracts (OpenAPI 3.1)
2. `design/`: Design Tokens ดึงจาก Figma และ Wireframes
3. `services/`: ซอร์สโค้ดแยกตามโมดูล (Frontend, Backend)
4. `runtime/`: รันไทม์พกพาเฉพาะโปรเจกต์
5. `staging/`: พื้นที่ทดสอบ AI และ Human Verify Gate
6. `repo/`: ซอร์สโค้ดสะอาดสำหรับซิงค์ขึ้น GitHub

---

**การนำทาง (Navigation):** [🏠 หน้าหลัก (Home)](../../README.md) | [🏛️ สถาปัตยกรรม (Architecture)](01_ARCHITECTURE.md) | [🔒 กฎ 2 ชั้น (Two-Tier Rules)](02_TWO_TIER_RULES.md) | [🎭 Playwright MCP](03_PLAYWRIGHT_MCP_SPEC.md) | [📜 ข้อกำหนด (Licenses)](04_TOOLING_AND_LICENSES.md) | [⬆️ กลับด้านบน (Top)](#top)

**ผู้พัฒนาและดูแลโครงการ:** [@rathanon-dev](https://github.com/rathanon-dev) · **สัญญาอนุญาต:** [MIT](../../LICENSE)
