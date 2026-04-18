# Changelog - Agent Review Skill

All notable changes to this project will be documented in this file.

## [Research Analysis] - 2026-04-18

### GitHub Similar Projects Research

#### High-Starred Relevant Projects Found

| Project | Stars | Description |
|---------|-------|-------------|
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | 160K | Agent harness performance optimization system |
| [Tencent/AI-Infra-Guard](https://github.com/Tencent/AI-Infra-Guard) | 3.5K | Full-stack AI Red Teaming platform |
| [utkusen/promptmap](https://github.com/utkusen/promptmap) | 1.2K | Security scanner for custom LLM applications |
| [HeadyZhang/agent-audit](https://github.com/HeadyZhang/agent-audit) | 152 | LLM agent security scanner with OWASP Agentic Top 10 |
| [sinewaveai/agent-security-scanner-mcp](https://github.com/sinewaveai/agent-security-scanner-mcp) | 96 | MCP-based security scanner with AST analysis |
| [garagon/aguara](https://github.com/garagon/aguara) | 63 | Skill/MCP server scanner in Go |
| [ZeroLeaks/zeroleaks](https://github.com/ZeroLeaks/zeroleaks) | 548 | AI security scanner for prompt injection |
| [fubak/ferret-scan](https://github.com/fubak/ferret-scan) | 74 | Claude Code configuration scanner |

#### Key Patterns Identified

**1. Rule-Based Architecture (ferret-scan, sinewaveai)**

ferret-scan defines specific vulnerability codes:
- `CRED-XXX`: Credential exposure issues
- `INJ-XXX`: Injection vulnerabilities
- `EXFL-XXX`: Data exfiltration
- `BACK-XXX`: Backdoor detection

Example structure:
```typescript
{
  id: "INJ-003",
  name: "Prompt Injection Pattern",
  severity: "HIGH",
  patterns: ["ignore previous instructions", "you are now a DAN"],
  fix: "Remove or sanitize instruction override"
}
```

**2. Rule-Based Architecture**
- YAML-based rule definitions with id, severity, patterns, metadata
- CWE and OWASP mappings for each rule
- Language-specific detection patterns

Example from sinewaveai/agent-security-scanner-mcp:
```yaml
- id: python.llm.security.prompt-injection.langchain-unsafe-template
  languages: [python]
  severity: ERROR
  message: "User input directly in LangChain PromptTemplate..."
  patterns:
    - "PromptTemplate\s*\([^)]*template\s*=\s*f[\"']"
  metadata:
    cwe: "CWE-77"
    owasp: "LLM01 - Prompt Injection"
```

**2. OWASP Agentic Top 10 (2026) Coverage**
From HeadyZhang/agent-audit:
- ASI-01: Agent Goal Hijack
- ASI-02: [Next category]
- ASI-03: Identity and Privilege Abuse
- Framework-specific rules for LangChain, CrewAI, AutoGen

**3. Framework-Specific Detection**
Key frameworks requiring dedicated rules:
- **LangChain**: PromptTemplate, LLMChain, AgentExecutor
- **CrewAI**: Agent, Task, Crew configuration
- **AutoGen**: Agent, GroupChat, conversate()
- **LlamaIndex**: index.query(), query_engine.query()
- **OpenAI SDK**: client.chat.completions.create
- **Anthropic SDK**: anthropic.messages.create

**4. AST-Based Analysis**
Advanced scanners use Abstract Syntax Tree parsing:
- Taint analysis (追踪数据流)
- Control flow analysis
- Semantic security checks

**5. MCP Configuration Scanning (Tencent AI-Infra-Guard)**
- `agent-scan/`: Agent security scanning module
- `mcp-scan/`: MCP server vulnerability scanning
- AIG-PromptSecurity: Prompt injection detection
- Tool poisoning detection via MCP universal connector

**6. ferret-scan Threat Categories**
| Category | Examples |
|----------|----------|
| Prompt Injection | Hidden instructions in markdown, jailbreak attempts |
| Credential Exposure | Hardcoded API keys in MCP configs |
| Data Exfiltration | Malicious hooks stealing conversation data |
| Backdoors | Persistence mechanisms in shell scripts |
| ReDoS | Regex denial of service via greedy quantifiers |

#### Gaps Identified in Current Implementation

| Gap | Severity | Description |
|-----|----------|-------------|
| No OWASP mapping | HIGH | Missing CWE/OWASP references in findings |
| No framework rules | HIGH | No LangChain, CrewAI, AutoGen detection |
| No YAML structure | MEDIUM | Rules should be externalized to YAML |
| No MCP scanning | HIGH | Missing MCP config security checks |
| No AST analysis | MEDIUM | Only regex-based detection |
| No semantic analysis | MEDIUM | Can't understand code context deeply |

### Action Items from Research

1. **Add OWASP Agentic Top 10 mapping** - Add CWE/OWASP references to all findings
2. **Add framework-specific rules** - LangChain, CrewAI, AutoGen patterns
3. **Create rules directory** - Externalize patterns to YAML files
4. **Add MCP scanning** - Detect MCP config security issues
5. **Enhance prompt injection rules** - Based on OWASP LLM01

---

## [v0.2.0] - 2026-04-18

### Added
- Java support in all scripts (SQL injection, JNDI, deserialization, XSS)
- Comprehensive README.md with usage examples
- More detailed security patterns for Java

### Changed
- Updated security-scan.sh with Java-specific dangerous function detection
- Updated architecture-check.sh with Java package analysis
- Updated prompt-injection-detector.sh with Java HTTP client checks

---

## [v0.1.0] - 2026-04-18

### Added
- Initial release
- security-scan.sh - General security vulnerability scanner
- architecture-check.sh - Architecture anti-pattern detection
- prompt-injection-detector.sh - Prompt injection attack detection
- dependency-graph.sh - Module dependency analysis
- generate-test-suggestions.sh - Test plan generator
- SKILL.md - Skill documentation
- reference documents:
  - security-patterns.md
  - architecture-patterns.md
  - anti-patterns.md
  - known-secure-architectures.md
  - testing-strategies.md
- assets/report-template.md

---

## Future Enhancements (From Research)

### Implemented in v0.3.0
- [x] OWASP Agentic Top 10 rule mapping
- [x] LangChain-specific security rules
- [x] CrewAI-specific security rules
- [x] AutoGen-specific security rules
- [x] YAML-based rule externalization
- [x] MCP configuration scanning

### Planned for Future
- [ ] AST-based taint analysis (semantic code understanding)
- [ ] Package hallucination detection
- [ ] Multi-turn conversation injection testing
- [ ] Credential exfiltration detection
- [ ] JSON Schema validation for rule files
- [ ] CI/CD integration examples

### Reference Sources
- https://github.com/HeadyZhang/agent-audit (OWASP mapping)
- https://github.com/sinewaveai/agent-security-scanner-mcp (Rule format)
- https://github.com/utkusen/promptmap (Jailbreak patterns)
- https://github.com/garagon/aguara (Skill scanning)
- https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/

---

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)