<a id="top"></a>

# 🔒 Two-Tier Hermetic Separation Standard
[⬅️ Back to Main README](../../README.md) | [🇹🇭 อ่านฉบับภาษาไทย](../th/02_TWO_TIER_RULES.md)

---

## 1. Tier 1 (AI Control Plane)
- **Location:** `tools/`, `.mcp/`, `.skills/`
- **Scope:** Dedicated strictly to AI Agent Cognition & Orchestration.
- **Host Detachment Axiom:** AI Agents MUST execute all tools using the hermetic Tier 1 toolchain (`tools/git`, `tools/node`, `tools/python312`). **Never rely on or invoke global Host binaries.**
- **Negative Rule:** Never execute `npm install` or `pip install` for project dependencies in Tier 1.

---

## 2. Tier 2 (Project Data Plane)
- **Location:** `projects/<project_name>/runtime/`
- **Scope:** Isolated execution environment per project.
- **Containment:** All dependencies (`node_modules`, `.venv`, CUDA DLLs) remain 100% confined inside that project pod without contaminating Tier 1 Base.

---

---

**Navigation:** [🏠 Home](../../README.md) | [🇹🇭 Thai](../../README.th.md) | [🇬🇧 English](../../README.en.md) | [🏛️ Architecture](01_ARCHITECTURE.md) | [🎭 Playwright MCP](03_PLAYWRIGHT_MCP_SPEC.md) | [⬆️ Back to Top](#top)

**Maintainer:** [@rathanon-dev](https://github.com/rathanon-dev) · **License:** [MIT](../../LICENSE) · [View All Credits](../../README.md#-credits--acknowledgements)
