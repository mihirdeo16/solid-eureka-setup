---
name: automic-vault
description: Use secrets and environment variables through Automic Vault (the `av` CLI) instead of .env files. Use whenever a command needs an API key, token, password or other env var, when wiring a third-party service into an idea, when a repo contains or expects a .env file, when publishing or deploying something that needs credentials, or when MD asks to store, add or rotate a secret.
---

# Automic Vault

MD's secrets and env vars live in Automic Vault, not in `.env` files. The `av` CLI hands a secret to one command at a time; the value never appears in the conversation, the shell history or a file.

## Rules

- Never read `.env` files or secret values, and never print, echo or log them.
- Never write a secret value into a file, a command line, a commit or a config.
- Before using a secret, ask MD first, naming the key and the purpose (for example: "I'm going to use `MY_API_KEY` to test the contact form locally"), and wait for approval.
- Ask for every key a task will need up front, in one go.
- Pass the secret only into the command that needs it. Do not export it into the shell.

## Workflow

1. **Find the key name.** `av list` prints the saved secret names (names only, never values). Match the name the code or service expects.
2. **If the key is missing,** ask MD to save it. Saving needs hidden input and an approval, so MD runs it themselves:

   ```sh
   av save KEY                              # global value
   av save --project-directory=. KEY        # value scoped to this project
   ```

   In Claude Code, suggest MD type `! av save KEY` so it runs in the session. Never ask MD to paste the value into the chat.
3. **Ask for approval** to use the key, naming key and purpose.
4. **Run the one command that needs it** through `av inject`:

   ```sh
   av inject +KEY -- <command>
   av inject +KEY_ONE +KEY_TWO -- <command>
   ```

   The secret is set as an environment variable of the same name for that command only.

## Other commands

| Command | Use |
| :- | :- |
| `av inject --replace-existing-env +KEY -- <cmd>` | The variable is already set in the environment and the vault value should win |
| `av inject --mode=fd +KEY:3 -- <cmd>` | The command can read the secret from a file descriptor; keeps it out of the environment |
| `av proxy +KEY -- <cmd>` | The command only sends the secret over HTTP/S; it gets a random reference and the proxy swaps in the real value on authorized requests |
| `av git <clone\|fetch\|pull\|push> <URL>` | Protected GitHub HTTPS git operations |
| `av scan` | Audit the machine or repo for exposed secrets and configuration |
| `av open` | Open the app; needed before an operation that requires Approval |
| `av history --since 7d` | Review what was authorized recently |

An approval covers one whole operation: the command, its arguments, the working directory and the requested keys. Changing any of them asks MD again, so settle the exact command before asking.

## In code and in repos

- Application code reads secrets from the environment (`os.environ["KEY"]`, `process.env.KEY`). It never loads a `.env` file, so do not add `python-dotenv`, `dotenv` or similar.
- Document the required key names (never values) in the README, with the run command written as `av inject +KEY -- <command>`.
- If a repo already has a `.env` file, do not open it. Tell MD, and suggest moving its keys into the vault with `av save` and then deleting the file.
- For deployed services, the secret belongs in the platform's own secret store. Set it by running the platform's CLI under `av inject`, never by pasting a value.

## If something fails

- `av` asks for approval and nothing happens: ask MD to run `av open`.
- A key is reported missing: check the exact name with `av list`, then ask MD to `av save` it.
- Run `av help` for the command surface of the installed build; docs are at https://www.automicvault.com/docs/.
