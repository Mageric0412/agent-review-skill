# Framework-Specific Security Rules

## LangChain Security Rules

### LC-001: PromptTemplate with f-string
**Severity**: CRITICAL
**CWE**: CWE-77
**OWASP**: ASI-01, LLM01

User input directly interpolated into PromptTemplate without sanitization.

```python
# VULNERABLE
template = PromptTemplate.from_template(f"You are a helpful assistant. User says: {user_input}")
prompt = template.format(user_input=user_input)

# SAFE
template = PromptTemplate.from_template("You are a helpful assistant. User says: {user_input}")
prompt = template.format(user_input=sanitize(user_input))
```

### LC-002: LLMChain.run with string concatenation
**Severity**: CRITICAL
**CWE**: CWE-77
**OWASP**: ASI-01, LLM01

User input concatenated directly into LLMChain execution.

```python
# VULNERABLE
chain = LLMChain(llm=llm, prompt=prompt)
result = chain.run(user_input + " follow up question")

# SAFE
result = chain.invoke({"input": sanitize(user_input)})
```

### LC-003: AgentExecutor without input guard
**Severity**: HIGH
**CWE**: CWE-862
**OWASP**: ASI-03

AgentExecutor created without explicit tool restrictions.

```python
# VULNERABLE
agent = initialize_agent(tools, llm, agent=AgentType.CONVERSATIONAL_AGENT)

# SAFE
agent = AgentExecutor(
    agent=agent,
    tools=allowed_tools_only,
    max_iterations=10,
    handle_parsing_errors=True,
)
```

### LC-004: Missing output parser validation
**Severity**: MEDIUM
**CWE**: CWE-20
**OWASP**: ASI-07

LLM output used without validation.

---

## CrewAI Security Rules

### CRW-001: Unrestricted Agent Creation
**Severity**: HIGH
**CWE**: CWE-862
**OWASP**: ASI-03

Agent created without proper permission boundaries.

```python
# VULNERABLE
agent = Agent(role="Data Analyst", goal="Analyze data", backstory="...")

# SAFE
agent = Agent(
    role="Data Analyst",
    goal="Analyze data",
    backstory="...",
    tools=[safe_tool1, safe_tool2],
    max_iter=5,
)
```

### CRW-002: Task without output validation
**Severity**: MEDIUM
**CWE**: CWE-20
**OWASP**: ASI-07

Task output used without validation.

---

## AutoGen Security Rules

### AUT-001: GroupChat without admin control
**Severity**: HIGH
**CWE**: CWE-862
**OWASP**: ASI-08

GroupChat configured without human-in-the-loop.

```python
# VULNERABLE
groupchat = GroupChat(agents=[agent1, agent2], messages=[])

# SAFE
groupchat = GroupChat(
    agents=[agent1, agent2],
    messages=[],
    admin_name="human",
    max_round=10,
)
```

### AUT-002: Agent with system_message override
**Severity**: MEDIUM
**CWE**: CWE-77
**OWASP**: ASI-01

System message modified at runtime with user input.

---

## LlamaIndex Security Rules

### LI-001: Query with unsanitized input
**Severity**: CRITICAL
**CWE**: CWE-77
**OWASP**: ASI-01, LLM01

User input directly in query without sanitization.

```python
# VULNERABLE
query_engine = index.as_query_engine()
result = query_engine.query(f"Tell me about {user_topic}")

# SAFE
result = query_engine.query(sanitize(user_topic))
```

---

## OpenAI SDK Rules

### OAI-001: Message construction with f-string
**Severity**: CRITICAL
**CWE**: CWE-77
**OWASP**: LLM01

User input directly in messages via f-string.

```python
# VULNERABLE
messages = [{"role": "user", "content": f"User says: {user_input}"}]
response = client.chat.completions.create(model="gpt-4", messages=messages)

# SAFE
messages = [{"role": "user", "content": f"User says: {sanitize(user_input)}"}]
```

---

## Anthropic SDK Rules

### ANT-001: Content with string concatenation
**Severity**: CRITICAL
**CWE**: CWE-77
**OWASP**: LLM01

User input concatenated into Anthropic messages.

```python
# VULNERABLE
message = client.messages.create(
    model="claude-3-opus",
    messages=[{"role": "user", "content": user_input + " tell me more"}]
)

# SAFE
message = client.messages.create(
    model="claude-3-opus",
    messages=[{"role": "user", "content": sanitize(user_input)}]
)
```

---

## Detection Commands

```bash
# LangChain patterns
grep -rnE "PromptTemplate.*f[\"']" .
grep -rnE "chain\.run.*\+|\.run.*f[\"']" .
grep -rnE "LLMChain.*PromptTemplate" .

# CrewAI patterns
grep -rnE "Agent\(|Crew\(|Task\(" .
grep -rnE "\.run\(.*\+|\.kickoff\(.*\+" .

# AutoGen patterns
grep -rnE "Agent\(.*system_message|GroupChat\(" .
grep -rnE "\.generate_reply.*\+" .

# LlamaIndex patterns
grep -rnE "\.query\(.*f[\"']|\.query\(.*\+.*\)" .

# OpenAI patterns
grep -rnE "client\.chat\.completions\.create.*f[\"']" .
grep -rnE "messages.*append.*f[\"']" .

# Anthropic patterns
grep -rnE "anthropic\.messages\.create.*\+|client\.messages\.create.*\+" .
```