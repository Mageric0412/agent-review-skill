# Architecture Patterns Reference

Known good architectures for agent systems.

## Layered Architecture

```
presentation/    # User interface, prompts
agent/           # Core decision logic
tools/           # Tool adapters
memory/          # State and persistence
```

### Benefits
- Clear separation of concerns
- Easy to test individual layers
- Scalable team structure

## Hexagonal Architecture

- **Core domain** isolated
- **Ports** for external adapters
- **No direct** external dependencies in core

### Ports
```
Input Ports: User commands, scheduled tasks
Output Ports: Database, external APIs, file system
```

## Clean Architecture

| Layer | Responsibility |
|-------|---------------|
| Entities | Core business objects |
| Use Cases | Application logic |
| Interface Adapters | Controllers, presenters |
| Frameworks | External tools, databases |

## Agent-Specific Patterns

### Memory Hierarchy

```
Working Memory (session state)
    |
    v
Short-term (daily logs)
    |
    v
Long-term (curated memory)
```

### Tool Abstraction

```
Tool Registry
    |
    +-- Capability-based routing
    +-- Graceful degradation
    +-- Timeout handling
```

### Decision Flow

```
User Input
    |
    v
Context Classification (trusted/untrusted)
    |
    v
Instruction Validation
    |
    v
Decision Engine
    |
    v
Action Planning
    |
    v
Tool Selection
    |
    v
Execution & Monitoring
```

## Secure Architecture Principles

### Least Privilege
- Each module has minimum required permissions
- Tool access gated by capability
- No standing permissions for sensitive actions

### Defense in Depth
- Multiple layers of validation
- Fail-secure defaults
- Independent verification

### Fail-safe Design
- Graceful degradation on component failure
- Circuit breakers for external calls
- State recovery mechanisms