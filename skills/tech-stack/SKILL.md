---
name: tech-stack
description: Choose the tech stack for a new idea and apply MD's conventions for that stack. Use when starting or scaffolding anything new, when asked which language, framework or tooling to use, when adding a new component (frontend, backend, CLI, desktop or mobile app) to an existing idea, or before writing Python, TypeScript, Flutter or Rust code in a repo that has no conventions of its own.
---

# Tech stack

Pick the stack from what is being built, not from habit. State the choice and the reason in the plan before scaffolding anything.

## 1. Choose by what is being built

| Building | Stack |
| :- | :- |
| A Python system: CLI tool, data/ML pipeline, backend service, research code | Python with `uv` |
| An all-web application | TypeScript, with Vite or Next.js (see Web) |
| A cross-platform application (mobile, or mobile + desktop + web from one codebase) | Flutter |
| A desktop-only application | Tauri (Rust core, web UI); Electron if it must reuse an existing web/Node codebase |
| A performance-critical component or system tool | Rust |
| Something that must fit an existing JVM codebase | Java |

Rules that apply to every row:

- An existing repo's stack wins. Identify it from the manifest files and stay in it; this table is for new ideas and new components.
- Stay inside this rotation: Python, TypeScript/JavaScript, Flutter, Rust, Java. If something else looks like a better fit, say why and ask before using it.
- If the idea spans two rows (for example a web UI over a Python system), use one stack per component and keep them in separate top-level folders.
- If it is unclear which row applies, ask MD which of the four shapes it is: cross-platform app, desktop-only app, all-web app, or Python system/CLI.

## 2. Python

- `uv` for the project (dependencies, venv, running code) and `uvx` for standalone dev tools. Never `pip`.
- Use the project's existing `.venv`. If there is none, tell MD; do not run `uv init` or create/sync a venv without asking.
- Lint and format with **ruff**, type-check with **ty**: both Rust-based, both run through `uvx` (`uvx ruff format .`, `uvx ruff check .`, `uvx ty check`), never added to `pyproject.toml`. They are a deployment-time step, not a per-change one; suggest them when a change looks deployment-related.
- No pytest or any other test framework unless MD explicitly asks for it. Test through each module's `if __name__ == "__main__":` block.
- Full type hints on every function signature.

Before writing Python code, read [references/python.md](references/python.md) for the project layout, config-driven design, entry-point pattern, assembler pattern and return-value contracts.

## 3. Web

- Always TypeScript, always React. No plain JavaScript files in new code.
- **Next.js** is the default: apps are multi-page, and it covers routing, server rendering and API routes in one place.
- **Vite + React** when the app is a client-only tool, dashboard or prototype with no server rendering or SEO need.
- Backend: Next.js route handlers for a web-only idea. If the idea already has a Python system behind it, the Python side is the backend and the web app only calls it.
- Package tooling: the repo's lockfile decides the package manager; for a new repo use `npm`, and run one-off tools with `npx`.

## 4. Flutter

- Use for anything cross-platform. Standard tooling only: `flutter` and `dart pub`.
- Keep UI, state and data access in separate layers from the first commit, so a prototype screen can grow into a full app.

## 5. Desktop and Rust

- Desktop-only: Tauri by default, with the same web stack as section 3 for the UI. Electron only when an existing web/Node codebase must be reused as is.
- Rust: `cargo` only, with `cargo fmt` and `cargo clippy` as the deployment-time checks.

## 6. Always

- Structure for scale regardless of size: entry point at the root, modules in a source folder, tunable behavior in a config file.
- Dependencies stay project-local. Never install into a global or system environment without asking MD first.
- Secrets go through Automic Vault; see the `automic-vault` skill.
