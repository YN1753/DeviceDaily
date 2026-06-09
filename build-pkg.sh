#!/bin/bash
# DeviceDaily 一键打包脚本
# 用法: ./build-pkg.sh

set -e

# ─── 配置 ──────────────────────────────────────────────
PROJECT_NAME="DeviceDaily"
SCHEME="DeviceDaily"
CONFIGURATION="Release"
BUILD_DIR="$(cd "$(dirname "$0")" && pwd)/build"
DERIVED_DATA="${BUILD_DIR}/DerivedData"
ARCHIVE_PATH="${BUILD_DIR}/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/export"
APP_PATH="${EXPORT_PATH}/${PROJECT_NAME}.app"
PKG_OUTPUT="${BUILD_DIR}/${PROJECT_NAME}.pkg"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 开始一键打包 ${PROJECT_NAME}...${NC}"

# 完全清理（包括系统 DerivedData 缓存）
rm -rf "${BUILD_DIR}"
rm -rf ~/Library/Developer/Xcode/DerivedData/${PROJECT_NAME}-*
mkdir -p "${EXPORT_PATH}"

# ─── Step 1: Clean ─────────────────────────────────────
echo -e "${BLUE}🧹 正在 Clean...${NC}"
xcodebuild clean \
  -project "${PROJECT_NAME}.xcodeproj" \
  -scheme "${SCHEME}" \
  -derivedDataPath "${DERIVED_DATA}" \
  -quiet

# ─── Step 2: Archive（主 App + Widget Extension 一起编译）──
echo -e "${BLUE}📦 正在 Archive（使用全新缓存目录）...${NC}"

xcodebuild archive \
  -project "${PROJECT_NAME}.xcodeproj" \
  -scheme "${SCHEME}" \
  -configuration "${CONFIGURATION}" \
  -destination 'generic/platform=macOS' \
  -archivePath "${ARCHIVE_PATH}" \
  -derivedDataPath "${DERIVED_DATA}"

echo -e "${GREEN}✅ Archive 完成${NC}"

# ─── Step 3: 提取 .app ─────────────────────────────────
echo -e "${BLUE}📤 正在提取 .app...${NC}"

ARCHIVED_APP="${ARCHIVE_PATH}/Products/Applications/${PROJECT_NAME}.app"

if [ ! -d "${ARCHIVED_APP}" ]; then
    echo -e "${RED}❌ 找不到 ${ARCHIVED_APP}${NC}"
    exit 1
fi

cp -R "${ARCHIVED_APP}" "${EXPORT_PATH}/"

# ─── Step 4: 验证 Widget Extension 已更新 ──────────────
WIDGET_EXT="${APP_PATH}/Contents/PlugIns/DeviceDailyWidgetExtension.appex"
if [ -d "${WIDGET_EXT}" ]; then
    echo -e "${GREEN}✅ Widget Extension 已嵌入${NC}"
    echo -e "${BLUE}   修改时间: $(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "${WIDGET_EXT}")${NC}"
else
    echo -e "${RED}❌ Widget Extension 未找到！${NC}"
    exit 1
fi

# ─── Step 5: 创建 PKG 安装包 ───────────────────────────
echo -e "${BLUE}📦 正在创建 PKG 安装包...${NC}"

productbuild \
  --component "${APP_PATH}" /Applications \
  "${PKG_OUTPUT}"

echo -e "${GREEN}✅ PKG 安装包创建成功！${NC}"

# ─── Step 6: 导出 .zip ─────────────────────────────────
ZIP_OUTPUT="${BUILD_DIR}/${PROJECT_NAME}.zip"
cd "${EXPORT_PATH}"
zip -rq "${ZIP_OUTPUT}" "${PROJECT_NAME}.app"
cd - > /dev/null

echo -e "${GREEN}📍 ZIP 压缩包: ${ZIP_OUTPUT}${NC}"

# ─── 完成 ──────────────────────────────────────────────
echo ""
echo "🎉 打包完成！"
echo ""
echo "   📦 ${PKG_OUTPUT}"
echo "   📦 ${ZIP_OUTPUT}"
echo ""
echo "📦 PKG: 双击安装到 Applications（会自动替换旧版本）"
echo ""
echo "⚠️  重要：安装后需要重新添加小组件！"
echo "   1. 右键桌面上的旧小组件 → 移除"
echo "   2. 桌面空白处右键 → 编辑小组件 → 重新添加"
echo ""

open "${BUILD_DIR}"
