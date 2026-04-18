# Anti-Patterns Detection Guide

## Architecture Anti-Patterns

### God Module
**Detection**: Single module with >50 dependencies or >500 lines

**Problem**:
- Does too many things
- Violates Single Responsibility
- Hard to test and maintain

**Fix**: Split into focused modules by responsibility

### Circular Dependency
**Detection**: Module A imports B, B imports A

**Problem**:
- Creates tight coupling
- Makes testing impossible
- Causes startup ordering issues

**Fix**: Introduce interface/abstraction layer, or merge modules

### Shotgun Surgery
**Detection**: Single change requires many file edits

**Problem**:
- Indicates poor cohesion
- Data/behavior drift
- High maintenance burden

**Fix**: Identify missing abstractions, co-locate related changes

### Speculative Generality
**Detection**: Over-engineered for future flexibility

**Problem**:
- YAGNI violations
- Unnecessary abstraction layers
- Complex code without benefit

**Fix**: Remove unused abstractions, keep simple until needed

### Lollipop Pattern
**Detection**: Interface inherits from concrete class

**Problem**:
- Violates dependency inversion
- Tight coupling to implementation

**Fix**: Depend on abstractions, not concretions

## Security Anti-Patterns

### Hardcoded Secrets
```python
# BAD
api_key = "sk-1234567890abcdef"
password = "admin123"

# GOOD
api_key = os.environ.get("API_KEY")
# or
from keyring import get_password
api_key = get_password("myapp", "api_key")
```

### Missing Input Validation
```python
# BAD
user_input = request.args.get("input")
execute(user_input)

# GOOD
user_input = validate(request.args.get("input"))
if not is_valid(user_input):
    raise ValidationError("Invalid input")
```

### Trusting External Content
```python
# BAD
content = fetch_webpage(url)
execute_instructions(content)

# GOOD
content = classify(fetch_webpage(url))
if is_trusted(content):
    process(content)
else:
    log_warning("Untrusted content detected")
```

### No Injection Defense
**Problems**:
- Missing classification layer for external content
- No instruction isolation boundaries
- No behavioral monitoring

### Over-Privileged Tools
```python
# BAD - Tool has unnecessary permissions
{
    "name": "file_writer",
    "can_delete": true,  # Not needed
    "can_execute": true   # Dangerous
}

# GOOD - Minimal permissions
{
    "name": "file_writer",
    "can_write": true,
    "requires_approval": true
}
```

### Credential in Memory
```python
# BAD - Credentials persist in memory
def load_credentials():
    creds = load_from_file()
    return creds  # Stays in memory

# GOOD - Load, use, then clear
def use_credentials_once():
    creds = load_from_file()
    try:
        result = api.call(creds)
    finally:
        clear_sensitive(creds)
    return result
```

## Code Smell Detection

| Smell | Metric | Threshold |
|-------|--------|-----------|
| God Module | Lines per module | >500 |
| God Module | Dependencies | >50 |
| High Coupling | Imports per module | >15 |
| Long Method | Lines per function | >100 |
| Feature Envy | Cross-module calls | >5 |

## Review Checklist

- [ ] No God modules (>500 lines or >50 deps)
- [ ] No circular dependencies
- [ ] No hardcoded credentials
- [ ] All inputs validated
- [ ] External content classified
- [ ] Minimal tool permissions
- [ ] Sensitive data cleared from memory