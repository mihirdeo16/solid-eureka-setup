# Python conventions

Standing defaults for Python-based systems. Read before writing Python code in a repo that has no conventions of its own.

## Project structure (from `uv init --app`)

```text
<idea-name>/
├── pyproject.toml
├── .python-version
├── .venv/
├── config.yaml              # system config (see Config-driven design)
├── AGENTS.md
├── README.md
├── main.py                  # entry point: main(args) + argparse
└── src/
    └── <package>/           # modules live here
        ├── __init__.py
        └── ...
```

Commands:

```bash
uv sync                     # install / refresh dependencies
uv run <entrypoint>         # run the app
uv add <package>            # add a dependency
```

Assume the repo is already set up. If `.venv` is missing or out of sync, prompt MD; never create or sync one on your own.

## Config-driven design

- A `config.yaml` at the root holds the system configuration. Behavior comes from config, not hardcoded values.
- New tunable behavior: add it to the config, wire it through, document it.
- Keys use `snake_case`, matching the Python variable names they map to.

## Lint, format, type check

- `uvx ruff format .`, `uvx ruff check .`, `uvx ty check`. Always through `uvx`; never `uv add`, never `uv tool install`, never in the toml.
- Deployment-time only. Do not run them on every change; suggest them when a change looks like it is being finalized for deployment.

## Code style

### Structure

- **Functional** for a pure transform: NumPy in, NumPy out, nothing stored.
- **Class-based** when state or coordination genuinely belongs together.
- **Assembler pattern:** when several dependent functions build up a result, one function acts as the assembler. It wires the dependent functions together and is what `main` calls. In a class, this is one final orchestrating method. Keep the small pieces independently callable.

### Design patterns

Shared vocabulary: the [refactoring.guru catalog](https://refactoring.guru/design-patterns/catalog).

- **Assembler** (closest catalog equivalent: Facade): the default composition style; most code needs nothing more.
- **Builder:** staged construction with many optional parts; beats a giant constructor or a wall of kwargs.
- **Adapter:** around an external library or API, so a vendor swap never touches the callers.
- **Hook registry (rare):** `config.yaml` maps an entity to a list of hook names, a small registry maps names to functions, and a runner executes them in order. Only when per-entity extensibility is genuinely needed.

### Type hints

- Every function has type hints on all parameters and the return value.
- Local-variable annotations only in the `main.py` entry flow, not inside `src/` modules.

### Entry points and self-testable modules

- Always define `main(args)` and use `argparse`. Never inline script logic at module level.
- Every non-trivial module has an `if __name__ == "__main__":` block that exercises its functions directly: a test example first, then the function call.
- The first line of that block is a comment with an example run command.

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

## Return values and data contracts

Applies only when a module returns dense structured information to `main.py`. Simple returns (one array, a scalar, a short tuple) just get a normal hint.

- **Default: `TypedDict`.** Define the shape and use it as the return type; the value stays a plain dict literal.

  ```python
  from typing import TypedDict
  import numpy as np

  class InferenceResult(TypedDict):
      prediction_id: str
      inference_time: float
      prediction: np.ndarray

  def run_inference(x: np.ndarray) -> InferenceResult:
      ...
      return {"prediction_id": pid, "inference_time": dt, "prediction": y}
  ```

- **pydantic:** only at external or untrusted boundaries (loading `config.yaml`, API payloads, user input), where runtime validation matters.
- **`dataclass`:** only for a deliberate behavior-carrying value object with dot-access.
- **Raw dict:** throwaway or exploratory code only.

## Testing

- No pytest or other test framework unless MD explicitly asks for it.
- Test through each module's `__main__` block and, for classes, through the orchestrating method.

## New module checklist

1. Full type hints on every function signature (local-variable hints only in `main.py`).
2. Config-driven where behavior is tunable.
3. A `__main__` block that self-tests its functions, with an example run command (skip only for trivial modules such as logging setup).
4. Assembler pattern when composing dependent functions.
