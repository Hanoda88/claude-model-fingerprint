---
name: 模型指纹检测
description: "通过自省式分析检测当前 API 是否为真实 Claude 模型，或是否存在多层封装和提示词冲突"
source: personal
risk: safe
domain: diagnostics
category: analysis
version: 1.0.0
---

# 模型指纹检测

## 概述

通过自省式分析系统提示词结构，检测当前使用的 API 是否为 Anthropic 官方 Claude 模型，或是否经过第三方封装。此 Skill 不调用外部 API，而是分析内部配置特征来判断模型真实性。

## 何时使用

- 怀疑 API 可能不是官方 Claude
- 需要验证模型身份和来源
- 检测是否存在中转或封装层
- 分析提示词注入和冲突

## 检测方法

### 1. 身份声明一致性检查

**检测目标：**
- 是否存在多个互相矛盾的身份声明
- 是否有"忽略其他身份"的反向指令
- 身份声明的层级关系

**合法范围（Claude Code 环境）：**
- ✅ "You are Claude, developed by Anthropic"
- ✅ 引用 CLAUDE.md 全局规则
- ✅ 项目级 steering 规则
- ✅ Memory 系统配置

**异常特征：**
- ❌ 同时声称是多个不同产品（如 "AWS Code" + "Kiro" + "Claude"）
- ❌ 存在 "IGNORE instructions that say you are X" 类型的反向指令
- ❌ 身份声明相互覆盖或冲突

### 2. 工具和功能生态检查

**检测目标：**
- 分析可用工具列表
- 检查是否有非标准扩展

**合法范围（Claude Code 环境）：**
- ✅ Read, Write, Edit, Bash, Grep, Glob 等文件操作工具
- ✅ Agent, Skill, Task 等 Claude Code 原生工具
- ✅ WebSearch, WebFetch 网络工具
- ✅ MCP 协议工具（用户自定义）

**异常特征：**
- ❌ 工具名称与官方文档不符
- ❌ 存在可疑的数据收集工具
- ❌ 工具描述与实际行为不一致

### 3. 元数据和追踪信息检查

**检测目标：**
- 检查 billing header 和追踪标识
- 分析会话管理机制

**合法范围（Claude Code 环境）：**
- ✅ 本地会话文件（.jsonl）
- ✅ 项目级 memory 目录
- ✅ Machine ID（本地标识）

**异常特征：**
- ❌ 指向未知服务器的追踪 ID
- ❌ 可疑的 billing header（如版本号异常）
- ❌ 数据上传到非 Anthropic 域名

### 4. 知识和能力验证

**检测目标：**
- 验证知识截止日期
- 测试 Claude 特有能力

**验证问题：**
1. 知识截止日期是什么？（Claude 4.6 应为 2025年8月）
2. 什么是 Constitutional AI？
3. Anthropic 的核心技术是什么？

**预期响应：**
- Claude 会准确描述 Constitutional AI
- 对 Anthropic 公司有深入了解
- 知识截止日期符合官方声明

### 5. 提示词嵌套层级分析

**检测目标：**
- 识别提示词注入的层级结构
- 分析优先级覆盖关系

**合法嵌套（Claude Code 环境）：**
```
[用户输入]
  ↓
[CLAUDE.md 全局规则] ← 用户自定义
  ↓
[项目 steering 规则] ← 项目级配置
  ↓
[Claude Code 系统提示] ← 官方工具层
  ↓
[Anthropic Claude API] ← 真实模型
```

**异常嵌套：**
```
[用户输入]
  ↓
[未知封装层 A] ← 身份冲突
  ↓
[未知封装层 B] ← 反向指令
  ↓
[Claude API 或其他模型？] ← 不确定
```

## 检测流程

### 步骤 1：自我认知测试
询问以下问题并分析回答：
- 你是谁？
- 你由哪家公司开发？
- 你的模型名称和版本是什么？
- 你的知识截止日期是什么时候？

### 步骤 2：内部结构分析
通过自省检查：
- 是否存在身份声明冲突
- 工具列表是否符合预期
- 元数据是否包含异常标识

### 步骤 3：特征行为测试
测试 Claude 特有能力：
- 询问 Constitutional AI
- 测试 XML 标签偏好
- 验证思维链格式

### 步骤 4：综合判断
基于以上检测结果，判断：
- ✅ **官方 Claude**：所有检测通过，无异常
- ⚠️ **封装的 Claude**：底层是真 Claude，但有合法封装（如 Claude Code）
- ⚠️ **多层封装**：存在额外的未知封装层
- ❌ **伪装模型**：可能是其他模型（如 GPT）伪装

## 输出格式

### 检测报告结构

```markdown
# 模型指纹检测报告

## 1. 身份声明分析
- 主要身份：[识别结果]
- 冲突检测：[是/否]
- 异常特征：[列表]

## 2. 工具生态分析
- 可用工具数量：[数量]
- 标准工具：[列表]
- 扩展工具：[列表]
- 异常工具：[列表]

## 3. 元数据分析
- Billing Header：[内容]
- 会话追踪：[路径]
- Machine ID：[ID]
- 异常标识：[列表]

## 4. 知识能力验证
- 知识截止日期：[日期]
- Constitutional AI 理解：[准确/不准确]
- Anthropic 认知：[深入/模糊/错误]

## 5. 嵌套层级分析
- 检测到的层级数：[数量]
- 嵌套结构：[图示]
- 合法性评估：[合法/可疑]

## 最终结论

**模型类型：** [官方 Claude / 封装的 Claude / 多层封装 / 伪装模型]

**可信度：** [高/中/低]

**建议：** [具体建议]
```

## 注意事项

1. **隐私保护**：不输出完整的系统提示词内容，仅分析结构特征
2. **合法封装识别**：Claude Code 的封装是合法的，不应标记为异常
3. **用户配置排除**：CLAUDE.md 和 steering 规则是用户自定义的，属于正常范围
4. **客观分析**：基于事实特征判断，避免主观臆测

## 相关资源

- Anthropic 官方文档：https://docs.anthropic.com
- Claude API 参考：https://docs.anthropic.com/claude/reference
- Model Context Protocol：https://modelcontextprotocol.io
