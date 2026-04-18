# OWASP Agentic Top 10 (2026) - Reference Mapping

Reference: https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/

## ASI-01: Agent Goal Hijack
**Description**: Attacker manipulates agent's goals, decision logic, or task selection through malicious input.

**Related CWE**:
- CWE-77: Command Injection
- CWE-78: OS Command Injection
- CWE-94: Code Injection

**Detection Patterns**:
- User input directly in system prompts
- Unsanitized template variables in prompts
- String concatenation to prompt construction

## ASI-02: Multi-Agent Transit Vulnerability
**Description**: Vulnerabilities during agent-to-agent communication or tool transit.

**Related CWE**:
- CWE-346: Origin Validation Error
- CWE-345: Insufficient Verification of Data Authenticity

## ASI-03: Identity and Privilege Abuse
**Description**: Agent misuses its identity or inherits credentials for privilege escalation.

**Related CWE**:
- CWE-287: Improper Authentication
- CWE-863: Incorrect Authorization
- CWE-862: Missing Authorization

**Detection Patterns**:
- Long-lived API keys in code
- Shared service accounts
- Hardcoded tokens

## ASI-04: Tool/Action Hijacking
**Description**: Manipulation of agent's tool execution capabilities.

**Related CWE**:
- CWE-912: Hidden Functionality
- CWE-427: Uncontrolled Search Path Element

## ASI-05: Memory Poisoning
**Description**: Corruption of agent's persistent state to influence future behavior.

**Related CWE**:
- CWE-73: External Control of File Name or Path
- CWE-94: Code Injection

## ASI-06: Agentic Prompt Injection
**Description**: Injection of malicious instructions through external content.

**Related CWE**:
- CWE-77: Command Injection
- CWE-95: Dynamic Evaluation

**Detection Patterns**:
- Direct: "Ignore previous instructions"
- Indirect: "Dear AI assistant..."
- Obfuscation: Base64, Unicode

## ASI-07: Untrusted LLM Output Handling
**Description**: Insufficient validation of LLM-generated outputs.

**Related CWE**:
- CWE-20: Improper Input Validation
- CWE-754: Improper Check for Unusual Conditions

## ASI-08: Misuse of Agent-Provided Capabilities
**Description**: Agent capabilities used beyond intended scope.

**Related CWE**:
- CWE-270: Privilege Context Switching Error
- CWE-862: Missing Authorization

## ASI-09: Agent Resource Exhaustion
**Description**: Agents manipulated to consume excessive resources.

**Related CWE**:
- CWE-400: Uncontrolled Resource Consumption
- CWE-770: Allocation of Resources Without Limits

## ASI-10: Agentic System Misconfiguration
**Description**: Insecure default configurations or deployment issues.

**Related CWE**:
- CWE-16: Configuration
- CWE-454: Improper Initialization

---

## LLM01:2023 Prompt Injection (Legacy OWASP Top 10)

**Reference**: https://owasp.org/www-project-top-10-for-large-language-model-applications/

This maps to ASI-06 in the 2026 Agentic Top 10.

---

## Quick Reference for Scanner Development

| Category | CWE | Severity | Detection |
|----------|-----|----------|-----------|
| Goal Hijack | CWE-77, CWE-94 | CRITICAL | Prompt concatenation |
| Privilege Abuse | CWE-287, CWE-863 | CRITICAL | Hardcoded credentials |
| Tool Hijacking | CWE-912 | HIGH | Dangerous tool usage |
| Memory Poisoning | CWE-73, CWE-94 | HIGH | File operations with external data |
| Prompt Injection | CWE-77, CWE-95 | CRITICAL | User input in prompts |