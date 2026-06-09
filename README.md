# DeviceDaily

一款 macOS 原生应用，帮你追踪数码产品的**日均使用成本**，让每一笔消费都心中有数。

> 💡 买了新设备？输入价格和购买日期，自动计算每天花多少钱在使用它。

---

## 功能特性

- 📱 **设备管理**：记录名称、价格、购买日期、类型（手机/平板/电脑/手表/耳机/相机/游戏机）
- 🧮 **日均成本**：自动计算 `(购买价 − 售出价) ÷ 使用天数`
- 📊 **统计总览**：总价值、使用中设备数、总日均成本
- 🎨 **成本颜色**：绿色（<¥5/天）→ 橙色（¥5~20/天）→ 红色（>¥20/天）
- ✏️ **编辑设备**：点击列表行即可修改所有字段
- 🗑️ **删除设备**：行尾直接删除，或编辑弹窗内删除
- 📱 **桌面小组件**：设备列表 Widget，快速查看使用中设备及日均成本
- 🔒 **本地存储**：数据保存在本地，App 与 Widget 通过 App Group 共享

---

## 安装方式

### 方式一：直接安装 PKG（推荐）

1. 下载 `DeviceDaily.pkg`
2. 双击安装到 `Applications` 文件夹
3. 从启动台打开即可

### 方式二：拖拽安装

1. 下载 `DeviceDaily.zip` 并解压
2. 将 `DeviceDaily.app` 拖到 `Applications` 文件夹
3. 首次打开可能需要在 **系统设置 → 隐私与安全性** 中允许

### 方式三：源码编译（开发者）

```bash
git clone https://github.com/YN1753/DeviceDaily.git
cd DeviceDaily
./build-pkg.sh
```

---

## 使用流程

### 1. 添加第一个设备

打开 App 后点击右上角 **+** 按钮，填写：

| 字段 | 说明 |
|------|------|
| 产品名称 | 例如 "iPhone 16 Pro Max" |
| 购买价格 | 实际购入金额 |
| 购买日期 | 选择购入日期 |
| 产品类型 | 手机/平板/电脑/手表/耳机/相机/游戏机 |
| 使用状态 | 使用中 / 售出 / 废弃 / 送人 / 其他 |
| 内存/存储 | 仅手机/平板/电脑类型可选填 |

> 💡 **售出状态**：填写售出金额后，日均成本 = (购买价 − 售出金额) ÷ 天数

### 2. 查看统计

顶部显示三栏实时统计：

- **总价值**：所有设备的购买价总和
- **使用中设备**：状态为"使用中"的设备数量
- **总日均成本**：使用中设备的日均成本之和

### 3. 编辑设备

**点击列表中的任意一行**，即可弹出编辑窗口修改所有信息。

### 4. 删除设备

- 方式一：点击行尾右侧的 **×** 按钮直接删除
- 方式二：进入编辑弹窗，点击底部 **"删除设备"** 按钮

### 5. 添加桌面小组件

1. 桌面空白处 **右键 → 编辑小组件**
2. 搜索 **DeviceDaily**
3. 选择 **"设备列表"**（Medium 尺寸）
4. 添加到桌面

小组件会自动显示**使用中设备**，按日均成本从高到低排序。

> ⚠️ **注意**：添加/编辑/删除设备后，小组件会实时刷新。如未刷新，可重新添加小组件。

---

## 首次使用注意事项

### App Group 配置（如从源码运行）

如果自行编译运行，需要在 Xcode 中配置 App Group，否则主 App 与小组件**无法共享数据**：

1. 选中 `DeviceDaily` Target → **Signing & Capabilities** → **+ Capability** → **App Groups**
2. 点击 **+** 添加 `group.com.heavensstarry.DeviceDaily`
3. 选中 `DeviceDailyWidgetExtension` Target → 重复上述步骤

---

## 打包发布

项目内置一键打包脚本：

```bash
./build-pkg.sh
```

输出：
- `build/DeviceDaily.pkg` — macOS 安装包
- `build/DeviceDaily.zip` — 压缩包
- `build/export/DeviceDaily.app` — 原始应用

---

## 应用图标

应用图标使用 SwiftUI 绘制，文件位于 `AppIconPreview.swift`。

导出方式：
1. 在 Xcode 中打开 `AppIconPreview.swift`
2. Canvas 预览 → 右键 → **Export** → 保存为 1024×1024 PNG
3. 将图片命名为 `icon_source.png`，放到 `DeviceDaily/Assets.xcassets/AppIcon.appiconset/`
4. 运行 `./generate-icons.sh` 生成所有尺寸

---

## 技术栈

- **SwiftUI** — 原生 macOS UI
- **WidgetKit** — 桌面小组件
- **App Groups + UserDefaults** — 主 App 与 Widget 数据共享
- **productbuild** — PKG 安装包

---

## 开发环境

- macOS 15+
- Xcode 16+
- Swift 5.9+

---

## License

MIT
