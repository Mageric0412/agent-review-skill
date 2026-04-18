# Known Secure Architectures

## Reference Implementations

### OpenAI Agent SDK
- Sandboxed tool execution
- Structured output validation
- Minimal state persistence
- Security-focused default configurations

### LangChain Agents
- Tool abstraction layer
- Memory segmentation
- Prompt injection defenses in parsers

### Anthropic Claude Agents
- Constitutional AI principles
- Tool use audit logging
- Human-in-loop for sensitive actions
- Vault integration for credentials

## Security Comparisons

| Architecture | Injection Defense | Credential Handling | State Isolation |
|--------------|-------------------|---------------------|-----------------|
| OpenAI SDK | Output parsing | API key only | Stateless |
| LangChain | Parser validation | Environment | Modular |
| Claude | Constitutional | Vault integration | Persistent |

## Implementation Lessons

### What Works
1. **Defense in depth** - Multiple security layers
2. **Least privilege** - Minimal tool permissions
3. **Fail-safe defaults** - Default to denying
4. **Audit logging** - Track all sensitive actions

### What Doesn't Work
1. **Single-layer security** - One bypass = compromise
2. **Trusting all input** - Especially external content
3. **Standing permissions** - Always require re-authorization
4. **Hidden credentials** - Secrets will be found