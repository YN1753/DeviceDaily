//
//  Constants.swift
//  DeviceDaily
//
//  Created by Claude on 2026/6/8.
//

import Foundation

enum AppConfig {
    /// App Group 标识符，主 App 和小组件共用 UserDefaults 存储
    ///
    /// ⚠️ 必须配置，否则主 App 和 Widget 数据不互通：
    ///   1. 选中 DeviceDaily Target → Signing & Capabilities → + Capability → App Groups
    ///   2. 点击 + 添加: group.com.heavensstarry.DeviceDaily
    ///   3. 选中 DeviceDailyWidgetExtension Target → 重复上述步骤
    ///   4. 在 https://developer.apple.com/account/resources/identifiers/list/applicationGroup
    ///      确认该 App Group ID 已注册（或使用 Xcode 自动修复）
    ///
    static let appGroupIdentifier = "group.com.heavensstarry.DeviceDaily"
}
