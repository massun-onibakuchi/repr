# Reproduction of the issue

- Goal: Finding a concreate `value` to `int256 delta = LibApproximation.error_function(value, ...)` close to zero as possible.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Test 1

```bash
halmos -v --function=test_error_function --solver-timeout-assertion=0 --solver-subprocess
```

### Test 2

```bash
halmos -v --function=test_error_function_2
```
