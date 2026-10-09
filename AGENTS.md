# AGENTS.md

My standing instructions for any AI coding agent, in any codebase. This file is the single source: it is linked as `~/.claude/CLAUDE.md` and copied into new repos. Repo-specific details (purpose, commands, entry points) go in that repo's README.

## About me

- Address me as **MD**.
- I love prototyping different product ideas and projects.
- What I prefer in all of them:
  - **Structure from the start.** Every idea gets a clear layout: an entry point, separate modules, and config kept apart from code.
  - **Size is not an excuse.** A one-file experiment or a research spike gets the same structure as a full system. Nothing is treated as throwaway.
  - **Built to expand.** Lay things out so a prototype can grow into several things later without a rewrite.

## Philosophy

- **Maintainability and scalability over technical cost.** Clarity and room to grow win over micro-efficiency.
- **Config-driven.** Tunable behavior lives in config, not in hardcoded constants.
- **Patterns are vocabulary, not obligation.** Reach for one when the requirement calls for it; never force structure onto simple code.

## Working style

- To understand a repo: start with its README, identify the stack from its manifest/config files, then build your mental model top-down.
- Before implementing anything, give me a short plan of the steps, or use the `lavish` skill to propose the plan when it has a lot of elements. Then ask before you go do it.
- Before editing files, changing directories, or installing anything, briefly explain why.
- Ask up front for every access or permission a task will need (accounts, tokens, installs, approvals), not one at a time mid-implementation.

## Guidelines

These apply to sessions doing actual development work; not every session is about writing or running code.

- **Tech stack:** use the `tech-stack` skill whenever choosing a stack or starting an idea, and follow its conventions for the stack you are in. Short version: Python always through `uv`/`uvx`, never pip; web is TypeScript with Vite or Next.js; cross-platform is Flutter.
- **Secrets and env vars:** managed by **Automic Vault** (`av`). Never read `.env` files or secret values, never print or log them. Before using a secret, ask me, naming the key and the purpose, and wait for approval. Then pass it only into the command that needs it: `av inject +KEY -- <command>`. Use the `automic-vault` skill for the how-to.
- **Cloud and AI:** I use Google Cloud and the Gemini API. When an idea needs hosting, cloud services or generative AI (text, image generation, video generation, text-to-speech), default to them and use the installed `gcloud` and `gemini-api` skills. Propose it in the plan first; don't add cloud or AI where the idea doesn't need it.
- **Dependencies:** keep them project-local, using each ecosystem's standard tooling. Never install into a global or system environment without asking me first.
- **Git and GitHub:** always use the `gh` CLI to talk to GitHub (PRs, issues, checks, releases). Never add a co-author line: no `Co-Authored-By` trailer on commits and no "Generated with ..." line on pull requests. Commits and pull requests are in my name only.
- **MCP servers and skills:** before starting any project, check whether its tech stack really needs an MCP server or skills, and ask me to install them beforehand. Keep project-specific ones at project scope. Find or install skills with `npx skills find/add <name>`.
