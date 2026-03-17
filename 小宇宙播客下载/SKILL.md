---
name: 小宇宙播客下载
description: Use when用户要求下载小宇宙播客音频，提供了小宇宙链接或播客名称
---

# 小宇宙播客下载

自动提取并下载小宇宙 (XiaoyuzhouFM) 的播客音频，支持单集和批量下载。

## 文件结构

```
小宇宙播客下载/
├── SKILL.md            # 本说明文件
├── batch_download.py   # 批量下载脚本
└── podcast_db.json     # 已收录播客数据库（名称→主页URL映射）
```

## 工作目录

`$PODCAST_DOWNLOAD_DIR`（建议配置为本地某个下载目录，如 `~/Downloads/podcasts`）

- `episodes.json` — 待下载的单集列表（由步骤 2 生成）
- `downloads/` — 下载输出目录，按播客名称自动创建子文件夹

## 步骤

### 1. 获取播客主页地址

- 先检查本 skill 目录下的 `podcast_db.json` 中是否已记录该播客的 URL
- 如果未找到，通过 `browser_subagent` 搜索并提取主页 URL，将结果追加到 `podcast_db.json`

### 2. 提取音频直链

使用 `browser_subagent` 访问页面：

- **单集链接**：直接打开页面，寻找 `audio` 标签或 `mediaUrl` 变量
- **播客主页**：解析节目列表，获取最新 N 期的详情页链接，逐一提取音频地址

**核心提取逻辑（在详情页运行）：**
```javascript
const data = JSON.parse(document.getElementById('__NEXT_DATA__').textContent).props.pageProps;
return {
    title: data.episode.title,
    podcast: data.podcast.title,
    audio_url: data.episode.mediaUrl
};
```

将结果写入工作目录的 `episodes.json`，格式：
```json
[
  {
    "title": "单集标题",
    "podcast": "播客名称",
    "audio_url": "https://media.xyzcdn.net/..."
  }
]
```

### 3. 批量下载

运行下载脚本：
```bash
python3 "$PODCAST_DOWNLOAD_DIR/batch_download.py"
```

脚本会读取 `episodes.json`，按播客名称在 `downloads/` 下创建子文件夹，自动跳过已存在的文件。

## 使用场景

- "帮我下载这个播客 [URL]"
- "帮我下载 [播客名称] 最近的 5 期"
