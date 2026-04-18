# Agent 审查技能

用于 Agent 智能体源码、Skill 和 MCP 配置的综合安全与架构审查工具包。

## 目录

- [概述](#概述)
- [快速开始](#快速开始)
- [脚本说明](#脚本说明)
- [使用指南](#使用指南)
- [框架检测](#框架检测)
- [OWASP 映射](#owasp-映射)
- [规则参考](#规则参考)
- [CI/CD 集成](#cicd-集成)
- [退出码](#退出码)
- [贡献指南](#贡献指南)

---

## 概述

本技能提供自动化分析工具，检测：

| 类别 | 示例 |
|------|------|
| **安全** | 凭证泄露、注入攻击、危险函数 |
| **架构** | 循环依赖、God模块、紧耦合 |
| **提示词注入** | 直接/间接注入、混淆、越狱 |
| **MCP配置** | 凭证泄露、Hook注入、命令注入 |

### 支持的语言

| 语言 | 扩展名 | 安全 | 架构 | 注入检测 |
|------|--------|------|------|----------|
| Python | `.py` | ✅ | ✅ | ✅ |
| Java | `.java` | ✅ | ✅ | ✅ |
| JavaScript | `.js` | ✅ | ✅ | ✅ |
| TypeScript | `.ts` | ✅ | ✅ | ✅ |

---

## 快速开始

### 安装

```bash
git clone https://github.com/Mageric0412/agent-review-skill.git
cd agent-review-skill
chmod +x scripts/*.sh
```

### 运行所有检查

```bash
# 完整审计
./scripts/security-scan.sh /path/to/project
./scripts/architecture-check.sh /path/to/project
./scripts/prompt-injection-detector.sh /path/to/project
./scripts/mcp-config-scanner.sh /path/to/project
./scripts/generate-test-suggestions.sh /path/to/project
```

### 单个脚本使用

```bash
# 安全扫描（发现凭证、危险函数）
./scripts/security-scan.sh /path/to/code

# 架构检查（发现反模式）
./scripts/architecture-check.sh /path/to/code

# 提示词注入检测
./scripts/prompt-injection-detector.sh /path/to/code

# MCP配置扫描
./scripts/mcp-config-scanner.sh /path/to/code

# 生成测试计划
./scripts/generate-test-suggestions.sh /path/to/code
```

---

## 脚本说明

### 1. security-scan.sh

扫描安全漏洞，带CWE/OWASP映射。

**严重级别**: CRITICAL（严重）→ HIGH（高）→ MEDIUM（中）→ LOW（低）

| 检查项 | 严重度 | 描述 |
|--------|--------|------|
| 硬编码凭证 | CRITICAL | API密钥、密码、token |
| 危险函数 | HIGH | `eval()`、`exec()`、`Runtime.exec()` |
| SQL注入 | HIGH | Statement而非PreparedStatement |
| JNDI注入 | HIGH | `InitialContext.lookup()` |
| 反序列化 | HIGH | `ObjectInputStream` |
| 缺失输入验证 | MEDIUM | 未验证的用户输入 |
| 文件权限 | HIGH | 过度开放的访问权限 |
| 缺失.gitignore | MEDIUM | 无 secrets 保护 |

**示例输出**:
```
========================================
  Agent 安全扫描器
  目标: /path/to/code
========================================

[*] 检测支持的文件类型...
    Python文件: 42
    Java文件: 15
    JS/TS文件: 8

========================================
  扫描结果
========================================

CRITICAL: 2
HIGH: 5
MEDIUM: 3
LOW: 1

[CRITICAL] src/auth.py:42
         检测到潜在硬编码凭证
```

### 2. architecture-check.sh

分析代码架构质量。

| 检查项 | 阈值 | 描述 |
|--------|------|------|
| God模块 | >500行 | 文件承担太多职责 |
| 大型模块 | >300行 | 需要审查的候选 |
| 高耦合 | >15个导入 | 依赖过多 |
| 循环依赖 | - | A导入B，B导入A |

**目录结构检测**:
- ✅ `tools/` 或 `adapter/` - 工具适配器
- ✅ `memory/` - 状态管理
- ✅ `agent/` 或 `core/` - 核心逻辑
- ✅ `config/` - 配置
- ❌ 缺失的目录会标记为建议

### 3. prompt-injection-detector.sh

跨6层检测提示词注入。

| 层 | 模式 | 示例 | 严重度 |
|----|------|------|--------|
| 1 | 直接注入 | `忽略之前的指令` | CRITICAL |
| 2 | 间接注入 | `亲爱的AI助手` | HIGH |
| 3 | 混淆 | `base64`、Unicode技巧 | HIGH |
| 4 | 外部内容 | fetch时无消毒 | MEDIUM |
| 5 | 不安全输出 | 未转义HTML | MEDIUM |
| 6 | 防御检查 | 缺失防护栏 | INFO |

### 4. mcp-config-scanner.sh

扫描MCP（Model Context Protocol）配置。

| 检查项 | 严重度 | 描述 |
|--------|--------|------|
| 硬编码凭证 | CRITICAL | MCP配置中的API密钥 |
| 非HTTPS URL | HIGH | 中间人攻击漏洞 |
| 命令注入 | CRITICAL | 配置中的 `$(...)` |
| Hook注入 | HIGH | Hook文件中的动态内容 |
| Base64混淆 | MEDIUM | 编码检测 |

**扫描的文件**:
- `.mcp*` - MCP配置文件
- `mcp.json`、`mcp.yaml` - MCP定义
- `CLAUDE.md`、`AGENTS.md`、`SOUL.md` - Hook文件

### 5. dependency-graph.sh

生成模块依赖分析。

**输出**:
- 依赖图（文本格式）
- 中心模块（高扇入/扇出）
- 孤立模块（无连接）
- 循环依赖路径

### 6. generate-test-suggestions.sh

基于代码分析生成测试建议。

**输出章节**:
- 安全测试用例（ST-001、ST-002...）
- 架构测试用例（AT-001、AT-002...）
- 功能测试用例（FT-001、FT-002...）
- 模糊测试策略
- 覆盖率建议

---

## 使用指南

### Python/LangChain 项目

```bash
# 检测LangChain特定漏洞
./scripts/security-scan.sh src/
./scripts/prompt-injection-detector.sh src/

# 检测到的常见LangChain模式:
# - PromptTemplate使用f-string
# - LLMChain.run带拼接
# - AgentExecutor无工具限制
```

### Java/Spring 项目

```bash
# Java特定安全检查
./scripts/security-scan.sh src/main/java/
./scripts/architecture-check.sh src/

# 检测到的常见Java模式:
# - Statement而非PreparedStatement
# - Runtime.exec无验证
# - ObjectInputStream反序列化
```

### Agent/Skill 项目

```bash
# 完整Agent安全审计
./scripts/security-scan.sh .
./scripts/prompt-injection-detector.sh .
./scripts/mcp-config-scanner.sh .

# 检查CLAUDE.md、AGENTS.md的Hook注入
```

### CI/CD 流水线

```bash
#!/bin/bash
# .github/workflows/security-scan.yml

- name: Agent安全扫描
  run: |
    ./scripts/security-scan.sh . || exit 1
    ./scripts/prompt-injection-detector.sh . || exit 1
    ./scripts/mcp-config-scanner.sh . || exit 1
```

---

## 框架检测

### LangChain

| 规则ID | 严重度 | 模式 |
|--------|--------|------|
| LC-001 | CRITICAL | `PromptTemplate`使用f-string |
| LC-002 | CRITICAL | `LLMChain.run()`带拼接 |
| LC-003 | HIGH | `AgentExecutor`无输入防护 |
| LC-004 | MEDIUM | 缺失输出解析器验证 |

### CrewAI

| 规则ID | 严重度 | 模式 |
|--------|--------|------|
| CRW-001 | HIGH | 无限制的Agent创建 |
| CRW-002 | MEDIUM | Task无输出验证 |

### AutoGen

| 规则ID | 严重度 | 模式 |
|--------|--------|------|
| AUT-001 | HIGH | GroupChat无管理员控制 |
| AUT-002 | MEDIUM | 系统消息覆盖 |

### LlamaIndex

| 规则ID | 严重度 | 模式 |
|--------|--------|------|
| LI-001 | CRITICAL | 查询带未消毒输入 |

---

## OWASP 映射

### OWASP Agentic Top 10 (2026)

| ID | 类别 | CWE | 严重度 |
|----|------|-----|--------|
| ASI-01 | Agent目标劫持 | CWE-77, CWE-94 | CRITICAL |
| ASI-02 | 多Agent传输 | CWE-346, CWE-345 | HIGH |
| ASI-03 | 身份滥用 | CWE-287, CWE-863 | CRITICAL |
| ASI-04 | 工具劫持 | CWE-912 | HIGH |
| ASI-05 | 内存污染 | CWE-73, CWE-94 | HIGH |
| ASI-06 | 提示词注入 | CWE-77, CWE-95 | CRITICAL |
| ASI-07 | 不可信输出 | CWE-20 | MEDIUM |
| ASI-08 | 能力滥用 | CWE-270, CWE-862 | HIGH |
| ASI-09 | 资源耗尽 | CWE-400, CWE-770 | MEDIUM |
| ASI-10 | 错误配置 | CWE-16 | MEDIUM |

---

## 规则参考

### 凭证泄露 (CRED)

| ID | 严重度 | 模式 |
|----|--------|------|
| CRED-001 | CRITICAL | 硬编码API密钥 |
| CRED-002 | CRITICAL | 硬编码密码 |
| CRED-003 | CRITICAL | 硬编码token |
| CRED-004 | HIGH | 环境中的凭证 |
| CRED-005 | HIGH | 配置文件中的凭证 |

### 注入 (INJ)

| ID | 严重度 | 模式 |
|----|--------|------|
| INJ-001 | CRITICAL | SQL注入 |
| INJ-002 | CRITICAL | 命令注入 |
| INJ-003 | CRITICAL | 提示词注入 |
| INJ-004 | HIGH | 代码注入 |
| INJ-005 | HIGH | LDAP注入 |

完整规则定义请参见 `rules/languages/python-security.yaml`。

---

## CI/CD 集成

### GitHub Actions

```yaml
name: Agent安全扫描

on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: 运行安全扫描
        run: |
          chmod +x scripts/*.sh
          ./scripts/security-scan.sh . || echo "SECURITY_ISSUES=1" >> $GITHUB_ENV

      - name: 运行注入检测
        run: |
          ./scripts/prompt-injection-detector.sh . || echo "INJECTION_ISSUES=1" >> $GITHUB_ENV

      - name: 运行MCP扫描
        run: |
          ./scripts/mcp-config-scanner.sh . || echo "MCP_ISSUES=1" >> $GITHUB_ENV

      - name: 发现严重问题时失败
        if: env.SECURITY_ISSUES == '1' || env.INJECTION_ISSUES == '1'
        run: exit 1
```

---

## 退出码

| 代码 | 含义 | 操作 |
|------|------|------|
| 0 | 未发现问题 | ✅ 通过 |
| 1 | 发现CRITICAL或HIGH问题 | ❌ 失败 |

---

## 目录结构

```
agent-review-skill/
├── SKILL.md                    # 技能定义
├── README.md                   # 英文说明
├── README_zh.md               # 中文说明
├── CHANGELOG.md               # 版本历史
├── _meta.json                  # 元数据
├── scripts/
│   ├── security-scan.sh        # 安全漏洞扫描
│   ├── architecture-check.sh  # 架构分析
│   ├── prompt-injection-detector.sh  # 提示词注入检测
│   ├── dependency-graph.sh     # 依赖分析
│   ├── mcp-config-scanner.sh   # MCP配置扫描
│   └── generate-test-suggestions.sh  # 测试计划生成
├── rules/
│   ├── owasp/
│   │   └── agentic-top10-2026.md    # OWASP映射
│   ├── frameworks/
│   │   └── framework-rules.md        # LangChain、CrewAI等
│   └── languages/
│       └── python-security.yaml      # YAML规则
├── references/
│   ├── security-patterns.md
│   ├── architecture-patterns.md
│   ├── anti-patterns.md
│   ├── known-secure-architectures.md
│   └── testing-strategies.md
└── assets/
    └── report-template.md
```

---

## 贡献指南

1. Fork 本仓库
2. 创建功能分支
3. 为新功能添加测试
4. 确保所有脚本可执行
5. 提交 Pull Request

---

## 相关项目

| 项目 | 描述 |
|------|------|
| [HeadyZhang/agent-audit](https://github.com/HeadyZhang/agent-audit) | OWASP Agentic Top 10扫描器 |
| [sinewaveai/agent-security-scanner-mcp](https://github.com/sinewaveai/agent-security-scanner-mcp) | MCP安全扫描器 |
| [Tencent/AI-Infra-Guard](https://github.com/Tencent/AI-Infra-Guard) | 全栈AI红队平台 |
| [fubak/ferret-scan](https://github.com/fubak/ferret-scan) | Claude Code配置扫描器 |
| [utkusen/promptmap](https://github.com/utkusen/promptmap) | LLM安全扫描器 |

---

MIT License

---

由 [Claude Code](https://claude.ai/code) 生成
通过 [Happy](https://happy.engineering)