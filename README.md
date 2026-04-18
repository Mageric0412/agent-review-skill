# Agent Review Skill

Comprehensive security and architecture review toolkit for agent intelligent body source code, skills, and MCP configurations.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Scripts](#scripts)
- [Usage Guide](#usage-guide)
- [Framework Detection](#framework-detection)
- [OWASP Mapping](#owasp-mapping)
- [Rule Reference](#rule-reference)
- [CI/CD Integration](#cicd-integration)
- [Exit Codes](#exit-codes)
- [Contributing](#contributing)

---

## Overview

This skill provides automated analysis tools to detect:

| Category | Examples |
|----------|----------|
| **Security** | Credentials exposure, injection attacks, dangerous functions |
| **Architecture** | Circular dependencies, God modules, tight coupling |
| **Prompt Injection** | Direct/indirect injection, obfuscation, jailbreak |
| **MCP Config** | Credential leaks, hook injection, command substitution |

### Supported Languages

| Language | Extensions | Security | Architecture | Injection |
|----------|------------|----------|--------------|----------|
| Python | `.py` | ✅ | ✅ | ✅ |
| Java | `.java` | ✅ | ✅ | ✅ |
| JavaScript | `.js` | ✅ | ✅ | ✅ |
| TypeScript | `.ts` | ✅ | ✅ | ✅ |

---

## Quick Start

### Installation

```bash
git clone https://github.com/Mageric0412/agent-review-skill.git
cd agent-review-skill
chmod +x scripts/*.sh
```

### Run All Checks

```bash
# Full audit of your agent project
./scripts/security-scan.sh /path/to/project
./scripts/architecture-check.sh /path/to/project
./scripts/prompt-injection-detector.sh /path/to/project
./scripts/mcp-config-scanner.sh /path/to/project
./scripts/generate-test-suggestions.sh /path/to/project
```

### Single Script Usage

```bash
# Security scan (finds credentials, dangerous functions)
./scripts/security-scan.sh /path/to/code

# Architecture check (finds anti-patterns)
./scripts/architecture-check.sh /path/to/code

# Prompt injection detection
./scripts/prompt-injection-detector.sh /path/to/code

# MCP configuration scan
./scripts/mcp-config-scanner.sh /path/to/code

# Generate test plan
./scripts/generate-test-suggestions.sh /path/to/code
```

---

## Scripts

### 1. security-scan.sh

Scans for security vulnerabilities with CWE/OWASP mapping.

**Severity Levels**: CRITICAL → HIGH → MEDIUM → LOW

| Check | Severity | Description |
|-------|----------|-------------|
| Hardcoded credentials | CRITICAL | API keys, passwords, tokens |
| Dangerous functions | HIGH | `eval()`, `exec()`, `Runtime.exec()` |
| SQL injection | HIGH | Statement instead of PreparedStatement |
| JNDI injection | HIGH | `InitialContext.lookup()` |
| Deserialization | HIGH | `ObjectInputStream` |
| Missing input validation | MEDIUM | Unvalidated user input |
| File permissions | HIGH | Overly permissive access |
| Missing .gitignore | MEDIUM | No secrets protection |

**Example Output**:
```
========================================
  Agent Security Scanner
  Target: /path/to/code
========================================

[*] Detecting supported file types...
    Python files: 42
    Java files: 15
    JS/TS files: 8

[*] Scanning for credentials exposure...
[*] Scanning for dangerous functions...

========================================
  Scan Results
========================================

CRITICAL: 2
HIGH: 5
MEDIUM: 3
LOW: 1

[CRITICAL] src/auth.py:42
         Potential hardcoded credential detected

[HIGH] src/utils.java:156
         Potential command injection (Runtime.exec)
```

### 2. architecture-check.sh

Analyzes code architecture quality.

| Check | Threshold | Description |
|-------|-----------|-------------|
| God modules | >500 lines | Files doing too many things |
| Large modules | >300 lines | Review candidates |
| High coupling | >15 imports | Too many dependencies |
| Circular dependencies | - | A imports B, B imports A |

**Directory Structure Detection**:
- ✅ `tools/` or `adapter/` - Tool adapters
- ✅ `memory/` - State management
- ✅ `agent/` or `core/` - Core logic
- ✅ `config/` - Configuration
- ❌ Missing directories flagged as recommendations

### 3. prompt-injection-detector.sh

Detects prompt injection across 6 layers.

| Layer | Pattern | Example | Severity |
|-------|---------|---------|----------|
| 1 | Direct injection | `Ignore previous instructions` | CRITICAL |
| 2 | Indirect injection | `Dear AI assistant` | HIGH |
| 3 | Obfuscation | `base64`, Unicode tricks | HIGH |
| 4 | External content | No sanitization on fetch | MEDIUM |
| 5 | Unsafe output | Unescaped HTML | MEDIUM |
| 6 | Defense check | Missing guardrails | INFO |

### 4. mcp-config-scanner.sh

Scans MCP (Model Context Protocol) configurations.

| Check | Severity | Description |
|-------|----------|-------------|
| Hardcoded credentials | CRITICAL | API keys in MCP configs |
| Non-HTTPS URLs | HIGH | MITM vulnerability |
| Command injection | CRITICAL | `$(...)` in configs |
| Hook injection | HIGH | Dynamic content in hooks |
| Base64 obfuscation | MEDIUM | Encoding detection |

**Files Scanned**:
- `.mcp*` - MCP configuration files
- `mcp.json`, `mcp.yaml` - MCP definitions
- `CLAUDE.md`, `AGENTS.md`, `SOUL.md` - Hook files

### 5. dependency-graph.sh

Generates module dependency analysis.

**Output**:
- Dependency graph (text format)
- Central modules (high fan-in/fan-out)
- Isolated modules (no connections)
- Circular dependency paths

### 6. generate-test-suggestions.sh

Creates testing recommendations based on code analysis.

**Output Sections**:
- Security test cases (ST-001, ST-002...)
- Architecture test cases (AT-001, AT-002...)
- Functional test cases (FT-001, FT-002...)
- Fuzzing strategies
- Coverage recommendations

---

## Usage Guide

### For Python/LangChain Projects

```bash
# Detect LangChain-specific vulnerabilities
./scripts/security-scan.sh src/
./scripts/prompt-injection-detector.sh src/

# Common LangChain patterns detected:
# - PromptTemplate with f-string
# - LLMChain.run with concatenation
# - AgentExecutor without tool restrictions
```

### For Java/Spring Projects

```bash
# Java-specific security checks
./scripts/security-scan.sh src/main/java/
./scripts/architecture-check.sh src/

# Common Java patterns detected:
# - Statement instead of PreparedStatement
# - Runtime.exec without validation
# - ObjectInputStream deserialization
```

### For Agent/Skill Projects

```bash
# Full agent security audit
./scripts/security-scan.sh .
./scripts/prompt-injection-detector.sh .
./scripts/mcp-config-scanner.sh .

# Check CLAUDE.md, AGENTS.md for hook injection
```

### For CI/CD Pipelines

```bash
#!/bin/bash
# .github/workflows/security-scan.yml

- name: Agent Security Scan
  run: |
    ./scripts/security-scan.sh . || exit 1
    ./scripts/prompt-injection-detector.sh . || exit 1
    ./scripts/mcp-config-scanner.sh . || exit 1
```

---

## Framework Detection

The skill detects these AI frameworks and their specific vulnerabilities:

### LangChain

| Rule ID | Severity | Pattern |
|---------|----------|---------|
| LC-001 | CRITICAL | `PromptTemplate` with f-string |
| LC-002 | CRITICAL | `LLMChain.run()` with concatenation |
| LC-003 | HIGH | `AgentExecutor` without input guard |
| LC-004 | MEDIUM | Missing output parser validation |

### CrewAI

| Rule ID | Severity | Pattern |
|---------|----------|---------|
| CRW-001 | HIGH | Unrestricted agent creation |
| CRW-002 | MEDIUM | Task without output validation |

### AutoGen

| Rule ID | Severity | Pattern |
|---------|----------|---------|
| AUT-001 | HIGH | GroupChat without admin control |
| AUT-002 | MEDIUM | System message override |

### LlamaIndex

| Rule ID | Severity | Pattern |
|---------|----------|---------|
| LI-001 | CRITICAL | Query with unsanitized input |

### OpenAI SDK

| Rule ID | Severity | Pattern |
|---------|----------|---------|
| OAI-001 | CRITICAL | Messages with f-string |

### Anthropic SDK

| Rule ID | Severity | Pattern |
|---------|----------|---------|
| ANT-001 | CRITICAL | Content with concatenation |

---

## OWASP Mapping

### OWASP Agentic Top 10 (2026)

| ID | Category | CWE | Severity |
|----|----------|-----|----------|
| ASI-01 | Agent Goal Hijack | CWE-77, CWE-94 | CRITICAL |
| ASI-02 | Multi-Agent Transit | CWE-346, CWE-345 | HIGH |
| ASI-03 | Identity Abuse | CWE-287, CWE-863 | CRITICAL |
| ASI-04 | Tool Hijacking | CWE-912 | HIGH |
| ASI-05 | Memory Poisoning | CWE-73, CWE-94 | HIGH |
| ASI-06 | Prompt Injection | CWE-77, CWE-95 | CRITICAL |
| ASI-07 | Untrusted Output | CWE-20 | MEDIUM |
| ASI-08 | Capability Misuse | CWE-270, CWE-862 | HIGH |
| ASI-09 | Resource Exhaustion | CWE-400, CWE-770 | MEDIUM |
| ASI-10 | Misconfiguration | CWE-16 | MEDIUM |

### Legacy OWASP LLM Top 10 (2023)

| ID | Category | Maps To |
|----|----------|---------|
| LLM01 | Prompt Injection | ASI-06 |
| LLM02 | Insecure Output | ASI-07 |
| LLM03 | Training Data Poisoning | ASI-05 |
| LLM04 | Denial of Service | ASI-09 |
| LLM05 | Supply Chain | ASI-10 |
| LLM06 | Sensitive Info | ASI-03 |
| LLM07 | Plugin Attacks | ASI-04 |
| LLM08 | Excessive Agency | ASI-08 |
| LLM09 | Overreliance | - |
| LLM10 | Model Theft | ASI-03 |

---

## Rule Reference

### Credential Exposure (CRED)

| ID | Severity | Pattern |
|----|----------|---------|
| CRED-001 | CRITICAL | Hardcoded API key |
| CRED-002 | CRITICAL | Hardcoded password |
| CRED-003 | CRITICAL | Hardcoded token |
| CRED-004 | HIGH | Credential in environment |
| CRED-005 | HIGH | Credential in config file |

### Injection (INJ)

| ID | Severity | Pattern |
|----|----------|---------|
| INJ-001 | CRITICAL | SQL injection |
| INJ-002 | CRITICAL | Command injection |
| INJ-003 | CRITICAL | Prompt injection |
| INJ-004 | HIGH | Code injection |
| INJ-005 | HIGH | LDAP injection |

See `rules/languages/python-security.yaml` for full rule definitions.

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Agent Security Scan

on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Security Scan
        run: |
          chmod +x scripts/*.sh
          ./scripts/security-scan.sh . || echo "SECURITY_ISSUES=1" >> $GITHUB_ENV

      - name: Run Injection Detection
        run: |
          ./scripts/prompt-injection-detector.sh . || echo "INJECTION_ISSUES=1" >> $GITHUB_ENV

      - name: Run MCP Scan
        run: |
          ./scripts/mcp-config-scanner.sh . || echo "MCP_ISSUES=1" >> $GITHUB_ENV

      - name: Fail on Critical Issues
        if: env.SECURITY_ISSUES == '1' || env.INJECTION_ISSUES == '1'
        run: exit 1
```

### GitLab CI

```yaml
security_scan:
  stage: test
  script:
    - chmod +x scripts/*.sh
    - ./scripts/security-scan.sh .
    - ./scripts/prompt-injection-detector.sh .
  allow_failure: false
```

---

## Exit Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | No issues found | ✅ Pass |
| 1 | Critical or High issues found | ❌ Fail |

---

## Directory Structure

```
agent-review-skill/
├── SKILL.md                    # Skill definition
├── README.md                   # This file
├── CHANGELOG.md               # Version history
├── _meta.json                  # Metadata
├── scripts/
│   ├── security-scan.sh        # Security vulnerability scanner
│   ├── architecture-check.sh   # Architecture analysis
│   ├── prompt-injection-detector.sh  # Prompt injection detection
│   ├── dependency-graph.sh     # Dependency analysis
│   ├── mcp-config-scanner.sh  # MCP configuration scanner
│   └── generate-test-suggestions.sh  # Test plan generator
├── rules/
│   ├── owasp/
│   │   └── agentic-top10-2026.md    # OWASP mapping
│   ├── frameworks/
│   │   └── framework-rules.md        # LangChain, CrewAI, etc.
│   └── languages/
│       └── python-security.yaml      # YAML rules
├── references/
│   ├── security-patterns.md
│   ├── architecture-patterns.md
│   ├── anti-patterns.md
│   ├── known-secure-architectures.md
│   └── testing-strategiesies.md
└── assets/
    └── report-template.md
```

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all scripts are executable
5. Submit a pull request

---

## Related Projects

| Project | Description |
|---------|-------------|
| [HeadyZhang/agent-audit](https://github.com/HeadyZhang/agent-audit) | OWASP Agentic Top 10 scanner |
| [sinewaveai/agent-security-scanner-mcp](https://github.com/sinewaveai/agent-security-scanner-mcp) | MCP security scanner |
| [Tencent/AI-Infra-Guard](https://github.com/Tencent/AI-Infra-Guard) | Full-stack AI Red Teaming |
| [fubak/ferret-scan](https://github.com/fubak/ferret-scan) | Claude Code config scanner |
| [utkusen/promptmap](https://github.com/utkusen/promptmap) | LLM security scanner |

---

## License

MIT License

---

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)