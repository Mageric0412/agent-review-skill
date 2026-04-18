---
name: agent-review
description: "Comprehensive security and architecture review skill for agent intelligent body source code. Use when: (1) User asks to review, audit, or assess an agent/skill codebase, (2) Security analysis is requested, (3) Architecture review is needed, (4) Before deploying new agent code. Trigger: 'review', 'audit', 'security', 'architecture', 'assess risks', 'check for vulnerabilities'."
---

# Agent Intelligent Body Review Skill

Comprehensive security and architecture review for agent source code and skills. Detects architectural anti-patterns, security vulnerabilities, and generates testing recommendations.

## Quick Reference

| Situation | Action |
|-----------|--------|
| Full security audit | Run `security-scan.sh` + `prompt-injection-detector.sh` |
| Architecture analysis | Run `architecture-check.sh` + `dependency-graph.sh` |
| Generate test plan | Run `generate-test-suggestions.sh` |
| Quick overview | Run all scripts in sequence |

## When to Use This Skill

Activate when user:
- Asks to "review", "audit", "assess" agent code
- Requests security analysis
- Wants architecture review
- Asks "is this agent secure?"
- Before deploying new agent/skill to production
- Asks to "check for vulnerabilities"

## Scripts Overview

### `scripts/security-scan.sh`
Scans for common security issues:
- Hardcoded credentials
- Dangerous functions (eval/exec)
- Missing input validation
- Insecure file permissions
- Missing .gitignore patterns

### `scripts/prompt-injection-detector.sh`
Detects prompt injection attack patterns:
- Direct injection (ignore instructions)
- Indirect injection (external content)
- Obfuscation techniques
- Missing defense layers

### `scripts/architecture-check.sh`
Analyzes architectural quality:
- Module size (God module detection)
- Coupling analysis
- Circular dependencies
- Separation of concerns

### `scripts/dependency-graph.sh`
Generates dependency analysis:
- Module dependency mapping
- Circular dependency detection
- Central module identification
- Isolated module detection

### `scripts/generate-test-suggestions.sh`
Creates testing recommendations:
- Security test cases
- Architecture test cases
- Functional test cases
- Fuzzing strategies

## Review Process

### Step 1: Initial Scan
```bash
# Identify codebase structure
ls -la
find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.js" \) | head -20
```

### Step 2: Security Analysis
```bash
./scripts/security-scan.sh [target-directory]
./scripts/prompt-injection-detector.sh [target-directory]
```

### Step 3: Architecture Analysis
```bash
./scripts/architecture-check.sh [target-directory]
./scripts/dependency-graph.sh [target-directory]
```

### Step 4: Generate Report
```bash
./scripts/generate-test-suggestions.sh [target-directory]
```

## Architecture Review Criteria

### Separation of Concerns
- [ ] Core agent logic separated from tools/adapters
- [ ] Memory/state management isolated
- [ ] Clear boundaries between layers

### Coupling Analysis
- [ ] No circular dependencies
- [ ] Fan-out reasonable (< 10 dependencies per module)
- [ ] No central "god" modules (>50 deps)

### State Management
- [ ] Stateless where appropriate
- [ ] Clear state transitions documented
- [ ] Recovery mechanisms present

## Security Analysis Criteria

### Prompt Injection Defense
- [ ] External content classified as untrusted
- [ ] Instruction isolation verified
- [ ] Behavioral monitoring in place
- [ ] Action gating for sensitive operations

### Credential Security
- [ ] No hardcoded credentials
- [ ] Proper permission model (600 for secrets)
- [ ] Runtime credential loading
- [ ] No credential exposure in logs

### Input Validation
- [ ] All external input validated
- [ ] Sanitization for any displayed content
- [ ] Bounds checking on data structures

## Output Format

Review reports are generated in markdown format with:
- Severity levels: CRITICAL, HIGH, MEDIUM, LOW
- File locations with line numbers
- Detailed descriptions
- Remediation recommendations

## Common Findings

### Architecture Issues
- Circular dependencies between memory and tools
- Tight coupling via direct module imports
- Missing abstraction layers
- God modules (>500 lines)

### Security Issues
- Credentials in environment variables (not file-protected)
- Missing input validation on external content
- No prompt injection defense layer
- Over-privileged tool access

## Related Skills

- `proactive-agent` - Security patterns reference
- `self-improving-agent` - Learning from findings
- `find-skills` - Find related skills if gaps identified

## References

- `references/security-patterns.md` - Extended security patterns
- `references/architecture-patterns.md` - Good architecture examples
- `references/anti-patterns.md` - Common anti-patterns to detect
- `references/testing-strategies.md` - Testing recommendations

## Source

- **Skill ID**: agent-review-001
- **Created**: 2026-04-18
- **Based on**: proactive-agent security patterns, self-improving-agent skill template
