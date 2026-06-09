//
//  AppStorage+Codable.swift
//  DeviceDaily
//
//  Created by Claude on 2026/6/8.
//

import SwiftUI
import WidgetKit

/// 让 [DigitalProduct] 可以通过 App Group 的 UserDefaults 进行 JSON 序列化存取
/// 主 App 和 Widget Extension 共享此存储
@propertyWrapper
struct ProductStorage: DynamicProperty {
    private let defaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier) ?? UserDefaults.standard

    var wrappedValue: [DigitalProduct] {
        get {
            guard let data = defaults.data(forKey: "products_key") else { return [] }
            return (try? JSONDecoder().decode([DigitalProduct].self, from: data)) ?? []
        }
        nonmutating set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: "products_key")
                // 数据变更时刷新小组件
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    var projectedValue: Binding<[DigitalProduct]> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
}
