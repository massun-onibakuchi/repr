# Reproduction of the issue

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```
    
```bash
halmos -v --no-test-constructor --function=test_error_function --solver-timeout-assertion=0 --print-failed-states --error-unknown --print-potential-counterexample
```