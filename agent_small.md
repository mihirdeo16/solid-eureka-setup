# AGENT.md

Baseline for AI coding agents in this repo. Condensed — see `agent_big.md` in the workspace_setup drafts for full detail and examples.

<!-- New-repo ritual: uv init --app → copy this file in as AGENT.md → echo 'See @AGENT.md' > CLAUDE.md -->
<!--
Note: this condensed file is the deployed contract; agent_big.md is the human reference doc.
If the agent drifts on the exact __main__ block shape (example command placement, argparse in
__main__, test-example-then-call order), paste the "Canonical entry-point pattern" snippet
from agent_big.md into this file — it's the single highest-value code block there.
-->

<!-- ## MCP & Skills
- **Scope: project-level.** Keep MCP servers and skills scoped to this project, not global/user scope. 
Example: claude mcp add-json github '{"type":"http","url":"https://api.githubcopilot.com/mcp","headers":{"Authorization":"Bearer YOUR_GITHUB_PAT"}}'
- **Installing / finding skills:** use **`npx skills add/find <NAME>`**. When I ask you to find or install a skill, use this command. -->
## Project

- Purpose: `<one sentence on what this system does>`
- Entry point: `main.py` at root; modules under `src/`; system config in `config.yaml` at root.

## Environment

- Only `uv` (project deps, running code) and `uvx` (dev tools). Never pip.
- The `.venv` already exists — always use it. Never run `uv init` or create/sync a venv without asking me first.
- Commands: `uv sync`, `uv run <entrypoint>`, `uv add <package>`.

## Config-driven design

- Behavior comes from `config.yaml` (snake_case keys), not hardcoded constants. New tunable behavior goes in the config and gets wired through.

## Lint & format

- Ruff, always via `uvx` — never added to the toml. Linting is a deployment-time step only; don't run it per change. Suggest it when a change looks deployment-related.

## Code style

- Full type hints on every function signature. Local-variable annotations only in the `main.py` entry flow.
- `main.py` defines `main(args)` with argparse — never inline script logic at module level.
- Every non-trivial module has an `if __name__ == "__main__":` block that exercises its functions independently, with an example run command in a comment on the first line.
- Assembler pattern: dependent functions get one assembler function (or one orchestrating method in a class) that composes them; keep the pieces independently callable.
- Functional style for pure transforms (NumPy in, NumPy out, nothing stored); classes only when state genuinely belongs together.
- Design patterns (vocabulary per the refactoring.guru catalog): assembler (≈ Facade) as the default composition; builder for staged construction with many optional parts; adapter around external libraries/APIs; and, rarely, a config-driven hook registry where config lists hooks to run per entity. Don't force patterns onto simple code.

## Return values

- When a module returns dense structured info to `main.py` (e.g. an inference result etc), define a `TypedDict` for the shape and use it as the return type — the value stays a plain dict. Simple returns just get a normal hint.

## Testing

- No pytest or any test framework. Test through each module's `__main__` block.

## MCP & skills

- Keep MCP servers and skills at project scope. Find/install skills with `npx skills`.

## Priorities

- Design for maintainability and scalability; don't optimize for technical cost.
