//
//  DigitalProduct.swift
//  DeviceDaily
//
//  Created by Claude on 2026/6/8.
//

import Foundation

enum ProductStatus: String, Codable, CaseIterable, Equatable {
    case inUse = "使用"
    case sold = "售出"
    case discarded = "废弃"
    case gifted = "送人"
    case other = "其他"

    var displayName: String { rawValue }
}

enum ProductType: String, Codable, CaseIterable, Equatable {
    case phone = "手机"
    case tablet = "平板"
    case computer = "电脑"
    case watch = "手表"
    case headphone = "耳机"
    case camera = "相机"
    case console = "游戏机"
    case other = "其他"

    var displayName: String { rawValue }

    /// 是否需要配置信息（内存、存储、芯片）
    var supportsConfig: Bool {
        self == .phone || self == .tablet || self == .computer
    }

    /// 对应图标
    var iconName: String {
        switch self {
        case .phone:     return "iphone"
        case .tablet:    return "ipad"
        case .computer:  return "laptopcomputer"
        case .watch:     return "applewatch"
        case .headphone: return "headphones"
        case .camera:    return "camera"
        case .console:   return "gamecontroller"
        case .other:     return "cube"
        }
    }
}

struct DigitalProduct: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var price: Double
    var purchaseDate: Date
    var productType: ProductType = .other
    var status: ProductStatus = .inUse
    var soldPrice: Double?        // 售出金额，仅在 status == .sold 时有效
    var customNote: String?       // 自定义备注，仅在 status == .other 时展示
    var endDate: Date?            // 结束时间，status != .inUse 时有效
    var ram: String?              // 内存，如 "32G"
    var storage: String?          // 存储，如 "512G"

    /// 已使用天数，最少为 1 天
    var daysUsed: Int {
        let calendar = Calendar.current
        let startOfPurchaseDate = calendar.startOfDay(for: purchaseDate)
        let startOfEndDate = calendar.startOfDay(for: endDate ?? Date())
        let components = calendar.dateComponents([.day], from: startOfPurchaseDate, to: startOfEndDate)
        return max(1, (components.day ?? 0) + 1)
    }

    /// 日均成本：售出状态需减去 soldPrice
    var costPerDay: Double {
        let effectivePrice: Double
        if status == .sold, let sold = soldPrice {
            effectivePrice = price - sold
        } else {
            effectivePrice = price
        }
        return effectivePrice / Double(daysUsed)
    }

    /// 状态展示文字
    var statusDisplay: String {
        if status == .other, let note = customNote, !note.isEmpty {
            return note
        }
        return status.displayName
    }

    /// 是否仍由当前用户持有，用于统计当前持有价值。
    var isCurrentlyOwned: Bool {
        status != .sold && status != .discarded && status != .gifted
    }

    /// 配置信息展示字符串，如 "32G · 512G"
    var configDisplay: String? {
        let parts = [ram, storage].compactMap { $0?.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
