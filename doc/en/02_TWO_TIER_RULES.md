<a id="top"></a>

# 🔒 Two-Tier Hermetic Separation Standard
[⬅️ Back to Main README](../../README.md) | [🇹🇭 อ่านฉบับภาษาไทย](../th/02_TWO_TIER_RULES.md)

---

## 1. Tier 1 (AI Control Plane)
- **Location:** `tools/`, `.mcp/`, `.skills/`
- **Scope:** Dedicated strictly to AI Agent Cognition & Orchestration.
- **Negative Rule:** Never execute `npm install` or `pip install` for project dependencies in Tier 1.

---

## 2. Tier 2 (Project Data Plane)
- **Location:** `projects/<project_name>/runtime/`
- **Scope:** Isolated execution environment per project.
- **Containment:** All dependencies (`node_modules`, `.venv`, CUDA DLLs) remain 100% confined inside that project pod.

---

[⬅️ Back to Main README](../../README.md) | [🏛️ System Architecture](01_ARCHITECTURE.md) | [⬆️ Back to Top](#top)
