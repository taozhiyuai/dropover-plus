# DropOverPlus

macOS 菜单栏应用，用于临时存放和拖放文件。类似 [Dropover](https://dropoverapp.com/) 的开源替代。

![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)

## 截图

![截图1](screenshot/screenshot-1.png)
![截图2](screenshot/screenshot-2.png)

## 功能

- 📦 **菜单栏图标** — 点击新建 Shelf，拖入文件暂存
- ⌨️ **快捷键** — `⌘⇧N` 快速新建 Shelf
- 🖱️ **拖入** — 将文件/文件夹拖入 Shelf 窗口
- 🚀 **拖出** — 从 Shelf 拖出到 Finder 或任意目标
- ✅ **多选** — 单击切换选中，`⌘+A` 全选，多文件一起拖出
- 🗑️ **清空** — 底部一键清空当前 Shelf
- 🔄 **拖放选项** — 拖放完成后可选择「移动」或「保留副本」
- ⚡ **启动即用** — 打开 App 自动创建一个 Shelf

## 快速开始

### 下载

直接下载 Release 版本，解压后双击运行：
https://github.com/taozhiyuai/dropover-plus/releases/latest

### 构建

```bash
git clone https://github.com/taozhiyuai/dropover-plus.git
cd dropover-plus
./build.sh
open build/DropOverPlus.app
```

首次使用如提示快捷键权限，请到 **系统设置 → 隐私与安全性 → 辅助功能** 添加本应用。

## 操作示意

| 操作 | 说明 |
|------|------|
| 拖文件到 Shelf | 暂存文件 |
| 从 Shelf 拖出 | 复制/移动到目标位置 |
| 单击文件图标 | 切换选中状态（绿色高亮）|
| `⌘+A` | 全选当前 Shelf 内文件 |
| 右键文件 | 打开 / 在 Finder 中显示 / 快速预览 |
| 底部红色按钮 | 清空当前 Shelf |

## 技术栈

- SwiftUI + AppKit 混编
- 原生拖放 API（NSDraggingSession）
- 兼容 macOS 14+

## 项目结构

```
DropOverPlus/
├── Sources/DropOverPlus/
│   ├── App.swift              # 入口 & 菜单栏
│   ├── ShelfManager.swift     # Shelf 管理
│   ├── ShelfWindowController.swift
│   ├── Models/Shelf.swift
│   ├── Views/
│   │   ├── ShelfPanelView.swift   # 主面板（含拖拽）
│   │   └── SettingsView.swift
│   └── Services/
│       ├── HotKeyManager.swift
│       └── QuickLookService.swift
├── AppIcon.icns
└── Package.swift
```
