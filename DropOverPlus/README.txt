DropOverPlus
============

一个 macOS 菜单栏应用，用于临时存放和拖放文件。类似 Dropover 的开源替代。

功能
----

- 从菜单栏图标新建 Shelf（临时文件存放窗口）
- 快捷键 ⌘⇧N 快速新建 Shelf
- 拖拽文件到 Shelf 窗口 → 暂存文件
- 从 Shelf 窗口拖出文件 → 拖到 Finder 或其他目标位置
- ⌘+A 全选文件
- 多选文件后拖动 → 所有选中文件一起拖拽
- 单击文件图标 → 切换选中状态（浅绿色高亮）
- 点击空白处 → 取消所有选中
- 右键文件 → 打开/在 Finder 中显示/快速预览/复制到剪贴板
- 底部「清空 Shelf」按钮 → 一键清空所有文件
- 拖放完成后弹出对话框，可选择「移动」（清理源文件）或「保留副本」
- 启动时自动创建一个 Shelf

使用方式
--------

1. 双击 DropOverPlus.app 启动
2. 菜单栏出现托盘图标 (tray.full)
3. 点击托盘图标 → 新建 Shelf
4. 拖拽文件到 Shelf 窗口暂存
5. 从 Shelf 窗口将文件拖出到目标位置

技术栈
------

- SwiftUI + AppKit 混编
- 原生拖放 API（NSDraggingSession）
- 兼容 macOS 14+

打包路径
--------

build/DropOverPlus.app
