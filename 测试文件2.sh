#!/bin/bash
# Build script for DropOverPlus
# Creates a standalone .app bundle

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/DropOverPlus"
BUILD_DIR="$SCRIPT_DIR/build"
APP_NAME="DropOverPlus"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "🔧 编译 DropOverPlus..."

cd "$PROJECT_DIR"

# Build with SwiftPM
swift build -c release --product DropOverPlus

# Locate the built binary
BINARY_PATH=$(swift build -c release --show-bin-path)/DropOverPlus
if [ ! -f "$BINARY_PATH" ]; then
    echo "❌ 编译产物未找到: $BINARY_PATH"
    exit 1
fi

echo "✅ 编译成功: $BINARY_PATH"

# Create .app bundle structure
echo "📦 创建 App Bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable
cp "$BINARY_PATH" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

# Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.dropoverplus.app</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>© 2026 DropOverPlus</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# Copy app icon (if available) - use a placeholder
# For now we skip the icon; macOS will use a default

echo "✅ App Bundle 已创建: $APP_BUNDLE"
echo ""
echo "✨ 使用方式:"
echo "   1. 双击打开 DropOverPlus.app"
echo "   2. 或者运行: open \"$APP_BUNDLE\""
echo ""
echo "⚠️  首次使用时需要授予权限:"
echo "   - 快捷键 ⌘⇧N 需要：系统设置 > 隐私与安全性 > 辅助功能"
echo "   - 如不需要快捷键，可直接忽略以上设置"
echo ""
echo "📋 核心功能:"
echo "   - 菜单栏图标 → 新建 Shelf"
echo "   - ⌘⇧N → 快速新建 Shelf"
echo "   - 拖拽文件到 Shelf 窗口 → 存放文件"
echo "   - 从 Shelf 窗口拖出文件 → 拖到目标位置"
echo "   - ⌘, → 打开设置"
