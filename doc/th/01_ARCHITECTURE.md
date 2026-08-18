<a id="top"></a>

# 🏛️ สถาปัตยกรรมระบบ MetaBase AI (LabBase-5)
[⬅️ กลับสู่หน้าหลัก (Back to README)](../../README.md) | [🇬🇧 Read in English](../en/01_ARCHITECTURE.md)

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

[⬅️ กลับสู่หน้าหลัก (Back to README)](../../README.md) | [📖 กฎการแยกขาด 2 ชั้น](02_TWO_TIER_RULES.md) | [⬆️ กลับขึ้นด้านบน (Back to Top)](#top)
