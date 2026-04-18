---
name: agent-review
description: "用于Agent智能体源码和Skill的安全与架构检视技能。当用户要求审查、审计或评估Agent/Skill代码库、请求安全分析、需要架构审查或在部署新Agent代码前使用时。触发词：review、audit、security、architecture、assess risks、check vulnerabilities、中文：审查、审计、安全、架构、检视。"
---

# Agent 智能体代码审查技能

用于Agent源码、Skill和MCP配置的安全与架构综合审查工具。检测架构反模式、安全漏洞，并生成测试建议。

## 快速参考

| 场景 | 操作 |
|------|------|
| 完整安全审计 | 运行 `security-scan.sh` + `prompt-injection-detector.sh` |
| 架构分析 | 运行 `architecture-check.sh` + `dependency-graph.sh` |
| 生成测试计划 | 运行 `generate-test-suggestions.sh` |
| MCP配置扫描 | 运行 `mcp-config-scanner.sh` |
| 快速概览 | 顺序运行所有脚本 |

## 何时使用此技能

当用户：
- 要求"审查"、"审计"、"评估"Agent代码
- 请求安全分析
- 需要架构审查
- 询问"这个Agent安全吗？"
- 在将新Agent/Skill部署到生产环境前
- 要求"检查漏洞"

## 脚本概览

### `scripts/security-scan.sh`
安全漏洞扫描：
- 硬编码凭证（API密钥、密码、token）
- 危险函数（eval、exec、Runtime.exec）
- 缺失的输入验证
- 不安全的文件权限
- SQL注入风险
- 反序列化漏洞
- JNDI注入

### `scripts/prompt-injection-detector.sh`
检测提示词注入攻击：
- 直接注入（忽略指令）
- 间接注入（外部内容）
- 混淆技术
- 缺失的防御层

### `scripts/architecture-check.sh`
架构质量分析：
- 模块大小（God模块检测）
- 耦合度分析
- 循环依赖
- 关注点分离

### `scripts/dependency-graph.sh`
依赖分析：
- 模块依赖映射
- 循环依赖检测
- 中心模块识别
- 孤立模块检测

### `scripts/generate-test-suggestions.sh`
生成测试建议：
- 安全测试用例
- 架构测试用例
- 功能测试用例
- 模糊测试策略

### `scripts/mcp-config-scanner.sh`
MCP配置扫描：
- 硬编码凭证
- 非HTTPS URL（中间人攻击风险）
- 命令注入
- Hook注入

## 审查流程

### 第一步：初始扫描
```bash
# 识别代码结构
ls -la
find . -type f \( -name "*.py" -o -name "*.java" \) | head -20
```

### 第二步：安全分析
```bash
./scripts/security-scan.sh [目标目录]
./scripts/prompt-injection-detector.sh [目标目录]
./scripts/mcp-config-scanner.sh [目标目录]
```

### 第三步：架构分析
```bash
./scripts/architecture-check.sh [目标目录]
./scripts/dependency-graph.sh [目标目录]
```

### 第四步：生成报告
```bash
./scripts/generate-test-suggestions.sh [目标目录]
```

## 架构审查标准

### 关注点分离
- [ ] 核心Agent逻辑与工具/适配器分离
- [ ] 内存/状态管理隔离
- [ ] 层与层之间边界清晰

### 耦合度分析
- [ ] 无循环依赖
- [ ] Fan-out合理（每模块<10个依赖）
- [ ] 无中心"God"模块（>50个依赖）

### 状态管理
- [ ] 适当的地方使用无状态
- [ ] 状态转换有文档
- [ ] 有恢复机制

## 安全分析标准

### 提示词注入防御
- [ ] 外部内容标记为不可信
- [ ] 验证指令隔离
- [ ] 有行为监控
- [ ] 敏感操作有动作门控

### 凭证安全
- [ ] 无硬编码凭证
- [ ] 正确的权限模型（600权限）
- [ ] 运行时加载凭证
- [ ] 日志中不暴露凭证

### 输入验证
- [ ] 所有外部输入都验证
- [ ] 显示内容经过消毒
- [ ] 数据结构有边界检查

## 支持的语言和框架

### 支持的语言
| 语言 | 文件扩展名 |
|------|------------|
| Python | `.py` |
| Java | `.java` |
| JavaScript | `.js` |
| TypeScript | `.ts` |

### 检测的框架
- **LangChain**: PromptTemplate, LLMChain, AgentExecutor
- **CrewAI**: Agent, Task, Crew
- **AutoGen**: Agent, GroupChat
- **LlamaIndex**: index.query()
- **OpenAI SDK**: client.chat.completions.create
- **Anthropic SDK**: anthropic.messages.create

## OWASP 映射

| ID | 类别 | CWE | 严重度 |
|----|------|-----|--------|
| ASI-01 | Agent目标劫持 | CWE-77, CWE-94 | 严重 |
| ASI-03 | 身份滥用 | CWE-287, CWE-863 | 严重 |
| ASI-06 | 提示词注入 | CWE-77, CWE-95 | 严重 |

## 输出格式

审查报告以markdown格式生成，包含：
- 严重级别：CRITICAL（严重）、HIGH（高）、MEDIUM（中）、LOW（低）
- 文件位置及行号
- 详细描述
- 修复建议

## 常见发现问题

### 架构问题
- 内存与工具间的循环依赖
- 通过直接模块导入的紧耦合
- 缺失的抽象层
- God模块（>500行）

### 安全问题
- 环境变量中的凭证（无文件保护）
- 外部内容缺失输入验证
- 无提示词注入防御层
- 过度授权的工具访问

## 相关技能

- `proactive-agent` - 安全模式参考
- `self-improving-agent` - 从发现问题中学习
- `find-skills` - 查找相关技能

## 参考文档

### 核心文档
- `references/security-patterns.md` - 扩展安全模式
- `references/architecture-patterns.md` - 良好架构示例
- `references/anti-patterns.md` - 常见反模式
- `references/testing-strategies.md` - 测试建议

### 安全标准
- `rules/owasp/agentic-top10-2026.md` - OWASP Agentic Top 10 (2026)
- `rules/frameworks/framework-rules.md` - 框架特定规则
- `rules/languages/python-security.yaml` - YAML格式规则

## 来源

- **技能ID**: agent-review-001
- **版本**: 0.4.0
- **创建日期**: 2026-04-18
- **基于**: proactive-agent安全模式、self-improving-agent技能模板