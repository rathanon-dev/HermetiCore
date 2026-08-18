# 🔑 HermetiCore Config & Credentials Hub

[⬅️ กลับสู่หน้าหลัก (Back to README)](../README.md)

โฟลเดอร์นี้ใช้สำหรับจัดเก็บไฟล์การตั้งค่า, สภาพแวดล้อมเฉพาะเครื่อง (`.env`), และกุญแจความปลอดภัยสำหรับ AI Workstation

## 📁 โครงสร้างไฟล์ในโฟลเดอร์นี้

* `env.example` — 📄 [Committed to Git] แม่แบบการตั้งค่าสภาพแวดล้อม (Environment Template)
* `.env` — 🔒 [Gitignored] ไฟล์เก็บ Token ลับจริงของเครื่องนี้ (สร้างโดยก๊อปปี้จาก `env.example`)
* `id_ed25519` — 🔑 [Gitignored] SSH Private Key สำหรับ Git Operations แบบ Zero-Prompt
* `id_ed25519.pub` — 📜 [Gitignored] SSH Public Key สำหรับนำไปเพิ่มใน [GitHub SSH Keys](https://github.com/settings/ssh/new)

---

## 🔒 กฎความปลอดภัย (Zero-Leak Policy)
ไฟล์ทั้งหมดที่มีนามสกุล `.env`, `*.key`, `id_ed25519*` จะถูกบล็อกโดย `.gitignore` เสมอ เพื่อป้องกันไม่ให้ความลับหรือรหัสผ่านรั่วไหลสู่ Public Repository 100% per ISO/IEC/IEEE 12207
