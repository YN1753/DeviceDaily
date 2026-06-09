#!/bin/bash

# DeviceDaily 一键打包脚本
# 用法: ./pack-dmg.sh

set -e

# 配置
PROJECT_NAME="DeviceDaily"
ARCHIVE_DIR="$HOME/Library/Developer/Xcode/Archives"
DMG_OUTPUT="$HOME/Desktop/${PROJECT_NAME}.dmg"
TEMP_DIR="/tmp/${PROJECT_NAME}-dmg-$$"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 查找最新的 Archive...${NC}"

# 找到最新的 .xcarchive
LATEST_ARCHIVE=$(find "$ARCHIVE_DIR" -name "${PROJECT_NAME}*.xcarchive" -type d -print0 2>/dev/null | xargs -0 ls -td 2>/dev/null | head -1)

if [ -z "$LATEST_ARCHIVE" ]; then
    echo -e "${RED}❌ 找不到 Archive${NC}"
    echo "请先执行 Xcode: Product → Archive"
    exit 1
fi

echo -e "📦 找到 Archive: $(basename "$LATEST_ARCHIVE")"

# 找到 .app
APP_PATH="$LATEST_ARCHIVE/Products/Applications/${PROJECT_NAME}.app"

if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ 找不到 ${PROJECT_NAME}.app${NC}"
    exit 1
fi

echo -e "✅ 找到 App: ${APP_PATH}"

# 检查是否包含 Widget Extension
WIDGET_EXT="$APP_PATH/Contents/PlugIns/DeviceDailyWidgetExtension.appex"
if [ -d "$WIDGET_EXT" ]; then
    echo -e "${GREEN}✅ 包含 Widget Extension${NC}"
else
    echo -e "${YELLOW}⚠️  未找到 Widget Extension${NC}"
fi

# 检查 create-dmg
if ! command -v create-dmg &> /dev/null; then
    echo -e "${YELLOW}⚠️  create-dmg 未安装${NC}"
    if command -v brew &> /dev/null; then
        echo -e "${BLUE}🍺 正在通过 Homebrew 安装 create-dmg...${NC}"
        brew install create-dmg
    else
        echo -e "${RED}❌ 请先安装 Homebrew: https://brew.sh${NC}"
        exit 1
    fi
fi

# 创建临时目录
mkdir -p "$TEMP_DIR"
cp -R "$APP_PATH" "$TEMP_DIR/"

echo -e "${BLUE}💿 正在创建 DMG...${NC}"

# 删除旧 DMG
rm -f "$DMG_OUTPUT"

# 创建 DMG
create-dmg \
  --volname "$PROJECT_NAME" \
  --window-size 600 400 \
  --icon-size 100 \
  --app-drop-link 450 185 \
  "$DMG_OUTPUT" \
  "$TEMP_DIR/${PROJECT_NAME}.app" 2>/dev/null || {
    echo -e "${YELLOW}⚠️  create-dmg 第一次运行可能失败（磁盘镜像已存在），重试中...${NC}"
    rm -f "$DMG_OUTPUT"
    create-dmg \
      --volname "$PROJECT_NAME" \
      --window-size 600 400 \
      --icon-size 100 \
      --app-drop-link 450 185 \
      "$DMG_OUTPUT" \
      "$TEMP_DIR/${PROJECT_NAME}.app"
  }

# 清理
rm -rf "$TEMP_DIR"

if [ -f "$DMG_OUTPUT" ]; then
    echo -e "${GREEN}✅ DMG 创建成功!${NC}"
    echo -e "${GREEN}📍 位置: ${DMG_OUTPUT}${NC}"
    echo ""
    echo "🎉 打包完成! 可以直接把这个 DMG 发给别人安装了。"
    open "$HOME/Desktop"
else
    echo -e "${RED}❌ DMG 创建失败${NC}"
    exit 1
fi
