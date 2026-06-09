#!/bin/bash
# DeviceDaily 图标生成脚本
# 用法:
#   1. 在 Xcode 中打开 AppIconPreview.swift，右键 Canvas → Export 保存为 icon_source.png（1024x1024）
#   2. 把 icon_source.png 放到 DeviceDaily/Assets.xcassets/AppIcon.appiconset/ 目录
#   3. 运行: ./generate-icons.sh

set -e

SRC="$(cd "$(dirname "$0")" && pwd)/DeviceDaily/Assets.xcassets/AppIcon.appiconset/icon_source.png"
OUTDIR="$(dirname "$SRC")"

if [ ! -f "$SRC" ]; then
    echo "❌ 找不到 icon_source.png"
    echo "请先在 Xcode 中预览 AppIconPreview.swift，导出 1024x1024 PNG 到:"
    echo "   $OUTDIR/icon_source.png"
    exit 1
fi

echo "🎨 正在从 1024x1024 源图生成各尺寸图标..."

# macOS 图标尺寸表
sizes=(
    "16:16:icon_16x16.png"
    "32:32:icon_16x16@2x.png"
    "32:32:icon_32x32.png"
    "64:64:icon_32x32@2x.png"
    "128:128:icon_128x128.png"
    "256:256:icon_128x128@2x.png"
    "256:256:icon_256x256.png"
    "512:512:icon_256x256@2x.png"
    "512:512:icon_512x512.png"
    "1024:1024:icon_512x512@2x.png"
)

for item in "${sizes[@]}"; do
    IFS=':' read -r w h name <<< "$item"
    sips -z "$h" "$w" "$SRC" --out "$OUTDIR/$name" >/dev/null 2>&1
    echo "✅ $name (${w}x${h})"
done

# 删除源图（可选）
rm "$SRC"

echo ""
echo "🎉 全部生成完成！在 Xcode 中 Build 即可看到新图标。"
