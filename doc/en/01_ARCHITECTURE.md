<a id="top"></a>

# 🏛️ MetaBase AI (LabBase-5) Architecture Specification
[⬅️ Back to Main README](../../README.md) | [🇹🇭 อ่านฉบับภาษาไทย](../th/01_ARCHITECTURE.md)

---

## 1. 3-Tier Layered Architecture Overview
The system cleanly separates architectural concerns:
- **Layer 1 (Meta-Framework Control Plane):** Manages AI tools, MCPs, and logging.
- **Layer 2 (Network & Acceleration Bus):** Bridges high-speed OmniProxy LAN caching.
- **Layer 3 (Project Pods):** 100% hermetically sealed application source and runtimes.

---

## 2. End-to-End Lifecycle Pipeline
1. `specs/`: Architecture specifications and OpenAPI 3.1 contracts.
2. `design/`: Figma design tokens and UI wireframes.
3. `services/`: Modular polyglot codebases (Frontend, Backend).
4. `runtime/`: Project-specific isolated toolchain.
5. `staging/`: Multi-stage AI and human verification gates.
6. `repo/`: Clean Git upstream repository.

---

---

**Navigation:** [🏠 Home](../../README.md) | [🇹🇭 Thai](../../README.th.md) | [🇬🇧 English](../../README.en.md) | [🔒 Two-Tier Rules](02_TWO_TIER_RULES.md) | [🎭 Playwright MCP](03_PLAYWRIGHT_MCP_SPEC.md) | [⬆️ Back to Top](#top)

**Maintainer:** [@rathanon-dev](https://github.com/rathanon-dev) · **License:** [MIT](../../LICENSE) · [View All Credits](../../README.md#-credits--acknowledgements)
