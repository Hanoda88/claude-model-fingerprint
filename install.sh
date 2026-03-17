#!/bin/bash

# Claude Code Skills 一键安装脚本
# https://github.com/bi-boo/claude-model-fingerprint

set -e

REPO="https://github.com/bi-boo/claude-model-fingerprint.git"
SKILLS_DIR="$HOME/.claude/skills"
TMP_DIR="/tmp/claude-skills-install"

SKILLS=(
  "公众号文章"
  "多视角对话素材"
  "会议方法论提炼"
  "文字稿润色"
  "长文结构优化"
  "API脚本化"
  "小宇宙播客下载"
  "模型指纹检测"
)

echo "Claude Code Skills 安装脚本"
echo "============================"
echo ""

# 克隆仓库
echo "正在下载 Skills..."
rm -rf "$TMP_DIR"
git clone --depth=1 "$REPO" "$TMP_DIR" 2>/dev/null
echo ""

# 创建 Skills 目录
mkdir -p "$SKILLS_DIR"

# 安装选择
echo "可安装的 Skills："
for i in "${!SKILLS[@]}"; do
  echo "  $((i+1)). ${SKILLS[$i]}"
done
echo ""
echo "输入编号安装单个（如 1），或直接回车安装全部："
read -r choice

if [ -z "$choice" ]; then
  # 安装全部
  for skill in "${SKILLS[@]}"; do
    cp -r "$TMP_DIR/$skill" "$SKILLS_DIR/"
    echo "已安装：$skill"
  done
else
  # 安装指定
  idx=$((choice - 1))
  skill="${SKILLS[$idx]}"
  if [ -n "$skill" ]; then
    cp -r "$TMP_DIR/$skill" "$SKILLS_DIR/"
    echo "已安装：$skill"
  else
    echo "无效编号"
    exit 1
  fi
fi

# 清理
rm -rf "$TMP_DIR"

echo ""
echo "安装完成！在 Claude Code 中使用 /<skill名称> 或自然语言触发。"
