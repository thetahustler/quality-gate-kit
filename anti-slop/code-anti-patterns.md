# Code Anti-Patterns (16 Patterns)

AI-generated code exhibits predictable failure modes. These 15 patterns appear across languages, frameworks, and project types. Each pattern includes what it looks like, why it's dangerous, how to detect it, and how to fix it.

---

## Pattern 1: Copy-Paste Between Files

**What it looks like:** The same logic (or near-identical logic) exists in two or more files.

**Example (Python):**
```python
# file_a.py
def calculate_tax(amount, rate):
    return round(amount * rate, 2)

# file_b.py  (copy-pasted, slightly different)
def calc_tax(amt, tax_rate):
    return round(amt * tax_rate, 2)
```

**Why it's dangerous:** A bug fix in one copy won't reach the other. Behavior diverges silently over time.

**How to detect:**
- Search for similar function signatures across files
- Use tools like `jscpd` (JS), `pylint --duplicate-code` (Python), or `flay` (Ruby)
- During review: if you see logic you've seen before, flag it

**How to fix:** Extract shared logic into a utility module. Import from one place.

---

## Pattern 2: Wrapper Functions That Pass Through

**What it looks like:** A function whose only job is to call another function with the same arguments.

**Example:**
```python
# Adds no value
def get_user(user_id):
    return database.fetch_user(user_id)
```

**Why it's dangerous:** Adds indirection without adding value. Makes the codebase harder to navigate. Every layer is a potential source of bugs.

**How to detect:** If a function body is a single return statement calling another function with identical arguments, it's a pass-through.

**How to fix:** Call the underlying function directly. If you need the wrapper for a future abstraction, document why in a comment.

---

## Pattern 3: File Bloat Past Threshold

**What it looks like:** A single file grows past 400 lines (configurable threshold).

**Why it's dangerous:** Large files are hard to review, hard to test, and accumulate unrelated concerns. AI agents produce worse output when working with large files due to context limitations.

**How to detect:**
```bash
# Find files over 400 lines
find . -name "*.py" -o -name "*.ts" -o -name "*.go" | xargs wc -l | awk '$1 > 400'
```

**How to fix:** Decompose BEFORE adding new code. Split by concern, not by arbitrary line count.

---

## Pattern 4: Happy-Path-Only Tests

**What it looks like:** Tests only verify the success scenario. No failure tests, no edge cases.

**Example:**
```python
def test_create_user():
    result = create_user("Alice", "alice@example.com")
    assert result.name == "Alice"
    # No test for: duplicate email, empty name, invalid email, database down
```

**Why it's dangerous:** Provides false confidence. The code "works" until it encounters any non-ideal input.

**How to detect:** For each test file, count success tests vs failure tests. If the ratio is >3:1, flag it.

**How to fix:** For every function, write at least one failure test and one edge case test. Test what happens when inputs are empty, null, oversized, or malformed.

---

## Pattern 5: Success-Only Mocks

**What it looks like:** Test mocks only return successful responses. No timeout, 4xx, 5xx, or empty response mocks.

**Example:**
```python
mock_api.get.return_value = {"status": 200, "data": {"id": 1}}
# Never tests: mock_api.get.side_effect = TimeoutError()
# Never tests: mock_api.get.return_value = {"status": 500}
```

**Why it's dangerous:** Error handling code is never exercised. When the API actually fails in production, the error handling (if it exists) runs for the first time.

**How to detect:** Search test files for mock setups. If all `.return_value` and no `.side_effect = Exception(...)`, flag it.

**How to fix:** Every mocked external call needs at least one test with a failure scenario: timeout, HTTP error, empty response, or malformed response.

---

## Pattern 6: Bare Except Blocks

**What it looks like:** Exception handlers that catch everything and do nothing.

**Example:**
```python
try:
    result = api.call()
except Exception:
    pass  # Silently swallowed
```

**Why it's dangerous:** Errors vanish. Debugging production issues becomes impossible because errors leave no trace.

**How to detect:**
```bash
# Python
grep -rn "except.*:" --include="*.py" | grep -v "# noqa"
```
Look for `except Exception: pass`, `except: pass`, or `except Exception as e:` followed by no logging.

**How to fix:** Every exception handler must: (1) log the error with context, (2) either recover gracefully or re-raise.

---

## Pattern 7: TODO/Placeholder for Critical Features

**What it looks like:** Shipping code with `TODO` comments for functionality that should exist.

**Example:**
```python
def retry_on_failure(func):
    # TODO: implement retry logic
    return func()
```

**Why it's dangerous:** The feature ships without the critical functionality. The TODO is forgotten. Production runs without retry logic.

**How to detect:**
```bash
grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.py" --include="*.ts" --include="*.go"
```

**How to fix:** Either implement it now or document it as a known limitation with a tracking issue.

---

## Pattern 8: Deleting/Weakening Existing Tests

**What it looks like:** Removing assertions, commenting out tests, or loosening checks to make new code pass.

**Example:**
```python
# Before: strict assertion
assert response.status_code == 200

# After: weakened to make new code pass
assert response.status_code in [200, 201, 204, 500]  # "500 is fine sometimes"
```

**Why it's dangerous:** If an existing test fails, the new code is wrong -- not the test. Weakening tests erodes the safety net.

**How to detect:** In PR diffs, look for deleted `assert` statements, commented-out test functions, or loosened assertions.

**How to fix:** If a test fails, fix the code. If the test is genuinely wrong, fix the test AND document why in the commit message.

---

## Pattern 9: Reinventing Standard Library

**What it looks like:** Custom utility functions that replicate what the standard library already provides.

**Example:**
```python
# Don't do this
def flatten_list(nested):
    result = []
    for item in nested:
        if isinstance(item, list):
            result.extend(flatten_list(item))
        else:
            result.append(item)
    return result

# Use this instead
from itertools import chain
list(chain.from_iterable(nested))
```

**Why it's dangerous:** Custom implementations are less tested, less optimized, and more likely to have edge case bugs than battle-tested standard libraries.

**How to detect:** Before writing any utility function, search for standard library equivalents.

**How to fix:** Use `pathlib`, `itertools`, `collections`, `functools`, `os.path`, etc. Check your language's standard library first.

---

## Pattern 10: Over-Abstraction

**What it looks like:** Multiple layers of classes, interfaces, or factories that add complexity without adding value.

**Example:**
```python
class UserServiceFactory:
    def create_service(self):
        return UserService(UserRepository(DatabaseConnection()))

# When all you needed was:
def get_user(user_id):
    return db.query("SELECT * FROM users WHERE id = ?", user_id)
```

**Why it's dangerous:** Every layer is a potential source of bugs, a place for state to go wrong, and a barrier to understanding. Abstraction is not inherently good -- it's good when it hides complexity that would otherwise be repeated.

**How to detect:** Count the layers between "user intent" and "actual work." If there are more than 2 intermediate layers, question each one.

**How to fix:** Start concrete. Introduce abstraction only when you have 2+ concrete cases that share a pattern.

---

## Pattern 11: Hallucinated Imports/APIs

**What it looks like:** Code references modules that don't exist, functions with wrong signatures, or APIs that were renamed.

**Example:**
```python
from utils.string_helpers import sanitize_html  # This module doesn't exist
response = api.get_user_profile(user_id, include_avatar=True)  # include_avatar isn't a real parameter
```

**Why it's dangerous:** Immediate runtime crash in production. Tests may pass if the import is mocked.

**How to detect:**
```bash
# Python: verify all imports resolve
python -c "import your_module"

# Run test discovery (catches import errors)
pytest --collect-only
```

**How to fix:** Always verify imports resolve and APIs match their actual signatures. Run `--collect-only` before the full test suite.

---

## Pattern 12: Verbose/Filler Code

**What it looks like:** Unnecessary comments, redundant logic, overly verbose implementations.

**Example:**
```python
# Get the user from the database
user = get_user(user_id)  # This comment adds nothing

# Check if user is not None
if user is not None:  # Could just be: if user:
    # Return the user's name
    return user.name  # Another useless comment
```

**Why it's dangerous:** Noise obscures signal. Critical logic hides among trivial comments. Code review attention is wasted on filler.

**How to detect:** Look for comments that restate the code. Look for verbose patterns that have idiomatic alternatives.

**How to fix:** Comments should explain WHY, not WHAT. Use idiomatic patterns for your language.

---

## Pattern 13: Tautological Tests

**What it looks like:** Tests that assert on mock return values, effectively testing the mock setup, not the code.

**Example:**
```python
def test_get_user():
    mock_db.get.return_value = {"name": "Alice"}
    result = get_user(1)
    assert result["name"] == "Alice"  # Just testing the mock returns what we told it to return
```

**Why it's dangerous:** The test proves nothing about the actual code behavior. If `get_user` is completely broken but returns the mock value, the test passes.

**How to detect:** If removing the function under test and replacing it with `return mock.return_value` still passes the test, it's tautological.

**How to fix:** Test behavior, not plumbing. Verify side effects (was the right query called?), transformation (did the function modify the data correctly?), or error handling (does it raise on bad input?).

---

## Pattern 14: Unsanitized User Input

**What it looks like:** External input passed directly to file paths, database queries, URLs, or shell commands.

**Example:**
```python
# SQL injection
query = f"SELECT * FROM users WHERE name = '{user_input}'"

# Path traversal
file_path = f"/uploads/{filename}"  # filename could be "../../etc/passwd"

# Command injection
os.system(f"convert {user_filename} output.png")
```

**Why it's dangerous:** Direct security vulnerability. Attackers can read files, execute queries, or run commands.

**How to detect:** Search for f-strings or string concatenation that include user-provided variables in SQL, file paths, URLs, or shell commands.

**How to fix:** Use parameterized queries, path sanitization (resolve + verify prefix), URL encoding, and subprocess with argument lists (not shell=True).

---

## Pattern 15: No Adversarial Input Tests

**What it looks like:** Functions accept external input but have no tests with malicious or unexpected inputs.

**Example:**
```python
def process_upload(filename, content):
    save_file(f"/uploads/{filename}", content)

# Tests only use: process_upload("report.pdf", b"...")
# Never tests: process_upload("../../etc/passwd", b"malicious")
# Never tests: process_upload("a" * 10000, b"oversized name")
# Never tests: process_upload("file\x00.pdf", b"null byte")
```

**Why it's dangerous:** The function may work perfectly for normal inputs but be exploitable with crafted inputs.

**How to detect:** For every function that accepts external input, check if test cases include malicious inputs.

**How to fix:** See `security/adversarial-input-patterns.md` for copy-paste test fixtures covering SQL injection, XSS, path traversal, oversized inputs, and null bytes.

---

## Pattern 16: Sync Mocks for Async Calls

**What it looks like:** Using `MagicMock()` for methods that are `await`-ed in the source code, instead of `AsyncMock()`.

**Example (Python):**
```python
# Source code
async def fetch_transactions(self):
    result = await self.zoho.list_transactions()  # awaited
    return result

# Test -- WRONG
mock_zoho = MagicMock()
mock_zoho.list_transactions = MagicMock(return_value=[...])  # Not awaitable!

# Test -- CORRECT
mock_zoho = MagicMock()
mock_zoho.list_transactions = AsyncMock(return_value=[...])  # Returns a coroutine
```

**Why it's dangerous:** `MagicMock` returns a `MagicMock` object, not a coroutine. When you `await` it, Python gets a non-awaitable object. In some test frameworks this silently passes (the mock is truthy), masking the fact that the real code path is never exercised. In production, the actual async call behaves completely differently.

**How to detect:**
- Search test files for `MagicMock` assignments to methods that are `await`-ed in source
- Run `grep -rn "= MagicMock(" tests/` and cross-reference with `await` usage in corresponding source files

**How to fix:** Use `AsyncMock` (from `unittest.mock`) for any method that is `await`-ed in source code. `AsyncMock` returns a coroutine that resolves to the `return_value`, matching real async behavior.
