# AGENT.md

<!--
New-repo ritual:
  1. uv init --app
  2. copy this AGENT.md into the repo root
  3. echo 'See @AGENT.md' > CLAUDE.md
Claude Code auto-reads CLAUDE.md; the @AGENT.md import pulls this file into context.

## MCP & Skills
- **Scope: project-level.** Keep MCP servers and skills scoped to this project, not global/user scope. 
Example: claude mcp add-json github '{"type":"http","url":"https://api.githubcopilot.com/mcp","headers":{"Authorization":"Bearer YOUR_GITHUB_PAT"}}'
- **Installing / finding skills:** use **`npx skills add/find <NAME>`**. When I ask you to find or install a skill, use this command.
-->

Baseline instructions for AI coding agents (Claude Code, Cursor, Aider, etc.) working in this repository. This file is the portable source of truth; `CLAUDE.md` is just a one-line pointer (`See @AGENT.md`).

Fill in the `<...>` placeholders when starting a new repo. Everything else is our standing default for Python-based system development.

---

## Project

- **Purpose:** `<one or two sentences on what this system does>`
- **Entry point:** `main.py` (script lives at project root; modules live under `src/`)

---

## Environment (non-negotiable)

The two tools we use for Python development are **`uv`** and **`uvx`**. Nothing else.

- Use **`uv`** for the project — dependencies, virtual environment, running code. **Never use `pip`.**
- Use **`uvx`** to run standalone dev tools (linter/formatter) without adding them to the project. Don't install dev tools into the project or the toml when `uvx` can run them ephemerally.
- **Assume the project is already set up.** The repo is normally created with `uv init --app` and the `.venv` already exists. **Always use that `.venv` Python.** Do **not** run `uv init`, and do **not** create a `.venv`.
- If `.venv` is missing or out of sync: **prompt me** — never create or sync one on your own.

### Project structure (from `uv init --app`)

```text
<project-name>/
├── pyproject.toml
├── .python-version          # <e.g. 3.14>
├── .venv/
├── config.yaml              # system config (see Config-driven design)
├── AGENT.md
├── CLAUDE.md                # one line: See @AGENT.md
├── README.md
├── main.py                  # entry point: main(args) + argparse
└── src/
    └── <package>/           # modules live here
        ├── __init__.py
        └── ...
```

### Commands you'll use

```bash
uv sync                     # install / refresh dependencies
uv run <entrypoint>         # run the app
uv add <package>            # add a dependency
```

---

## Config-driven design (core principle)

The system is **config-driven**. A `config.yaml` at the project root holds the system configuration for each datapoint. Behavior is determined by config, not hardcoded values.

- Read settings from `config.yaml`; don't scatter magic constants through the code.
- New tunable behavior → add it to the config, wire it through, document it.
- **Keys use `snake_case`** — matching the Python variable names they map to.
- `<describe the shape of config.yaml for this repo — top-level keys, per-datapoint fields>`

---

## Lint & format (ruff via `uvx`)

- Tool: **ruff**, always run through **`uvx`** (never `uv add`, never `uv tool install`, never in the toml).
- **Format:** `uvx ruff format .`
- **Lint:** `uvx ruff check .`

**When to lint:** Linting is a **deployment-time** step, not a per-commit one. Do **not** run `ruff check` on every change. Only apply it (and suggest it) when a change is **deployment-related** — detect this from the nature of the change and prompt me when it looks like we're finalizing for deployment.

---

## Code style

### Structure — config-driven + assembler pattern
- Drive behavior from config (see above).
- Choose **class-based** or **functional** per the requirement:
  - **Functional** when it's a pure transform — **NumPy in, NumPy out, nothing stored** (no hidden state).
  - **Class-based** when state/coordination genuinely belongs together.
- **Assembler pattern (modular composition):** when several dependent functions build up a result, there is **one function that acts as the assembler** — it wires the dependent functions together and is what `main`/tests call. In a class, this is **one final orchestrating method** that calls the others. Keep the small pieces independently callable; the assembler composes them.

### Design patterns

Shared vocabulary: the [refactoring.guru catalog](https://refactoring.guru/design-patterns/catalog). Preferred patterns and when to reach for each:

- **Assembler** (closest catalog equivalent: Facade) — the default composition style (defined above); most code needs nothing more.
- **Builder** — when an object or pipeline needs **staged construction** with many optional parts; beats a giant constructor or a wall of kwargs.
- **Adapter** — when integrating an **external library or API**: wrap it so the rest of the system sees our interface, and a vendor swap never touches the callers.
- **Hook registry (rare)** — config-driven hooks: `config.yaml` maps an entity to a **list of hook names**, a small registry maps names → functions, and a runner executes them in order ("for this entity, run these hooks"). Use only when per-entity extensibility is genuinely needed.

Patterns are vocabulary, not obligation — reach for one when the requirement calls for it; never force structure onto simple code.

### Type hints
- **Every function** has type hints on **all parameters and the return value** — everywhere, no exceptions.
- **Local-variable annotations** are reserved for the **`main.py` / main entry flow only.** Don't annotate local variables inside regular `src/` modules — just the function signatures there.

### Entry points
- Always define a **`main(args)`** function and use **`argparse`** for CLI arguments. Never inline script logic at module level.

### Self-testable modules
- Every module (except trivial ones like a logger setup) has an `if __name__ == "__main__":` block that **exercises its main function(s) directly**, so each function can be isolated and tested on its own.
  - If the module has independent functions, the block shows a **test example first, then the function call** — making it easy to isolate them.
  - Include a short comment/docstring in the block with an **example command** showing how to run it.

### Canonical entry-point pattern

`main.py` (and any runnable module) follows this exact shape — `main(args)`, then an `if __name__ == "__main__":` block whose **first line is the example run command**, then argparse:

```python
def main(args: argparse.Namespace) -> None:
    ...

if __name__ == "__main__":
    # Example: uv run main.py --config config.yaml --input data/sample.npy
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", required=True)
    args = parser.parse_args()
    main(args)
```

---

## Return values & data contracts

Applies **only when a module returns dense/structured information to `main.py`** — e.g. an inference result carrying `prediction_id`, `inference_time`, `prediction`, etc. For simple returns (a single array, a scalar, a short tuple) don't bother; just type-hint the return normally.

- **Default: `TypedDict`.** Define a `TypedDict` for the shape and use it as the function's return type. The return value stays a **plain dict literal** — nothing about the code changes, you just gain a documented, type-checked contract that `main.py` can read at a glance.

  ```python
  from typing import TypedDict
  import numpy as np

  class InferenceResult(TypedDict):
      prediction_id: str          # snake_case keys, matching the dict
      inference_time: float
      prediction: np.ndarray

  def run_inference(x: np.ndarray) -> InferenceResult:
      ...
      return {"prediction_id": pid, "inference_time": dt, "prediction": y}
  ```

- **Keys use `snake_case`**, matching the variable names.
- **pydantic** — only at **external / untrusted boundaries** (loading `config.yaml`, API payloads, user input), where you want real runtime *validation*. Not for internal module → `main` handoffs.
- **`dataclass`** — only when you deliberately want a behavior-carrying value object with dot-access; otherwise prefer `TypedDict` (keeps it a plain dict, serializes for free).
- **Raw dict** — throwaway / exploratory code only.

---

## Testing

- **No pytest.** Do not add pytest or any test framework.
- Test through each module's `__main__` block and, for classes, through the class's main dunder / orchestrating method — exercising functions independently.

---

## Design priorities

- Design for **maintainability and scalability** first. **Don't optimize for technical cost** — clarity and the ability to grow the system win over micro-efficiency.

---

## New file / module checklist

When creating a new file, make sure it:
1. Has full type hints on every function signature (local-variable hints only in `main.py`).
2. Is config-driven where behavior is tunable.
3. Has an `if __name__ == "__main__":` block that self-tests its functions, with an example run command (skip only for trivial modules like logging setup).
4. Uses the assembler pattern when composing dependent functions.

---

## Always / Never

**Always**
- Use `uv` (project) and `uvx` (dev tools) only; use the existing `.venv` Python.
- Keep the system config-driven via `config.yaml`.
- Give every function full signature type hints; wrap entry logic in `main(args)` + argparse.
- Make every module self-testable via `__main__`.

**Never**
- Never use `pip`, `uv init`, or create/sync a `.venv` without asking.
- Never add ruff to the toml or add pytest.
- Never run the linter on every commit — only for deployment.
- Never inline entry-point logic at module level.
- Never annotate local variables outside the main entry flow.
