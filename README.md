# Agent Review Skill

Comprehensive security and architecture review skill for agent intelligent body source code and skills.

## Overview

This skill provides automated analysis tools to detect:
- Security vulnerabilities (credentials exposure, injection attacks, dangerous functions)
- Architecture anti-patterns (circular dependencies, God modules, tight coupling)
- Prompt injection attack vectors
- Testing recommendations

## Supported Languages

| Language | Extensions | Security Scan | Architecture Check | Injection Detection |
|----------|------------|---------------|-------------------|---------------------|
| Python | `.py` | ✅ | ✅ | ✅ |
| Java | `.java` | ✅ | ✅ | ✅ |
| JavaScript | `.js` | ✅ | ✅ | ✅ |
| TypeScript | `.ts` | ✅ | ✅ | ✅ |

## Quick Start

```bash
# Clone this skill
git clone https://github.com/Mageric0412/agent-review-skill.git
cd agent-review-skill

# Run security scan
./scripts/security-scan.sh /path/to/your/agent/code

# Run architecture check
./scripts/architecture-check.sh /path/to/your/agent/code

# Detect prompt injection
./scripts/prompt-injection-detector.sh /path/to/your/agent/code

# Generate test suggestions
./scripts/generate-test-suggestions.sh /path/to/your/agent/code
```

## Scripts

### security-scan.sh

Scans for common security vulnerabilities:

| Check | Severity | Description |
|-------|----------|-------------|
| Hardcoded credentials | CRITICAL | API keys, passwords, tokens in source |
| Dangerous functions | HIGH | eval(), exec(), Runtime.exec() |
| Missing input validation | MEDIUM | Unvalidated user input |
| Insecure file permissions | HIGH | Files with overly permissive access |
| SQL injection risks | HIGH | Statement usage instead of PreparedStatement |
| Deserialization risks | HIGH | ObjectInputStream usage |
| JNDI injection | HIGH | InitialContext.lookup() without validation |

**Python specific:**
- `eval()`, `exec()`, `system()` calls
- Unvalidated `input()`, `request.` usage

**Java specific:**
- `Runtime.getRuntime().exec()` - command injection
- `ProcessBuilder` without validation
- `Statement` instead of `PreparedStatement` - SQL injection
- `ObjectInputStream` - deserialization
- `InitialContext.lookup()` - JNDI injection
- Missing XSS protection in output

### architecture-check.sh

Analyzes code architecture quality:

| Check | Threshold | Description |
|-------|-----------|-------------|
| God modules | >500 lines | Files doing too many things |
| Large modules | >300 lines | Review candidates |
| High coupling | >15 imports | Too many dependencies |
| Circular dependencies | - | Module A imports B, B imports A |
| Separation of concerns | - | Checks for tools/, memory/, agent/, config/ |

**Detects:**
- Layered architecture patterns
- Package-level circular dependencies (Java)
- Import-based circular dependencies (Python)
- Interface usage for abstraction (Java)
- Naming convention consistency

### prompt-injection-detector.sh

Detects prompt injection attack patterns across 6 layers:

| Layer | Pattern | Severity |
|-------|---------|----------|
| 1 | Direct injection (`Ignore previous instructions`) | CRITICAL |
| 2 | Indirect injection (`Dear AI assistant`) | HIGH |
| 3 | Obfuscation (`base64`, Unicode tricks) | HIGH |
| 4 | External content handling | MEDIUM |
| 5 | Unsafe output rendering | MEDIUM |
| 6 | Defense mechanisms | - |

### dependency-graph.sh

Generates module dependency analysis:
- Dependency graph visualization
- Central modules (high fan-in/fan-out)
- Isolated modules (no connections)
- Circular dependency paths

### generate-test-suggestions.sh

Automatically generates test recommendations:
- Security test cases
- Unit test coverage targets
- Integration test scenarios
- Fuzzing strategies
- Framework-specific recommendations

## Usage Examples

### Basic Security Audit

```bash
cd /path/to/your/agent/project

# Run all checks
./agent-review-skill/scripts/security-scan.sh .
./agent-review-skill/scripts/prompt-injection-detector.sh .
./agent-review-skill/scripts/architecture-check.sh .
```

### CI/CD Integration

```bash
#!/bin/bash
# exit 1 if critical issues found
./scripts/security-scan.sh . || exit 1
./scripts/prompt-injection-detector.sh . || exit 1
```

### Java Project Analysis

```bash
# Java-specific analysis
./scripts/security-scan.sh src/main/java/
./scripts/architecture-check.sh src/
./scripts/prompt-injection-detector.sh src/
```

### Python Project Analysis

```bash
# Python-specific analysis
./scripts/security-scan.sh src/
./scripts/architecture-check.sh .
./scripts/prompt-injection-detector.sh src/
```

## Report Template

Use `assets/report-template.md` for structured review reports:

```markdown
# Agent Review Report

**Date**: YYYY-MM-DD
**Target**: /path/to/agent-code

## Executive Summary
[High-level findings]

## Severity Summary
| Severity | Count |
|----------|-------|
| CRITICAL | X |
| HIGH | X |
| MEDIUM | X |
| LOW | X |

## Architecture Issues
[Detailed findings with recommendations]

## Security Issues
[Detailed findings with remediation]

## Test Recommendations
[Generated test plan]
```

## Architecture Patterns

See `references/architecture-patterns.md` for:
- Layered architecture
- Hexagonal architecture
- Clean architecture
- Agent-specific patterns

## Security Patterns

See `references/security-patterns.md` for:
- Prompt injection detection
- Credential security
- Defense layers
- Incident response

## Anti-Patterns

See `references/anti-patterns.md` for:
- God module detection
- Circular dependency patterns
- Shotgun surgery
- Speculative generality

## Testing Strategies

See `references/testing-strategies.md` for:
- Unit test guidelines
- Integration test scenarios
- Security testing
- Fuzzing approaches

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | No issues found |
| 1 | Critical or High severity issues found |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## License

MIT License

## Related

- [proactive-agent](https://github.com/Mageric0412/proactive-agent) - Security patterns reference
- [self-improving-agent](https://github.com/Mageric0412/self-improving-agent) - Learning from findings
- [AI-Testing-Benchmark](https://github.com/Mageric0412/AI-Testing-Benchmark) - Testing framework

---

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)