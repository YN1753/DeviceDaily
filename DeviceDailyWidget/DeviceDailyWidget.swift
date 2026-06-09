//
//  DeviceDailyWidget.swift
//  DeviceDailyWidget
//
//  Created by Claude on 2026/6/8.
//

import WidgetKit
import SwiftUI

// MARK: - 数据模型（与主 App 的 DigitalProduct 结构匹配）

struct WidgetProduct: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String = ""
    var price: Double = 0
    var purchaseDate: Date = Date()
    var productType: String = "other"
    var status: String = "使用"
    var soldPrice: Double?
    var customNote: String?
    var endDate: Date?
    var ram: String?
    var storage: String?

    var daysUsed: Int {
        let calendar = Calendar.current
        let end = endDate ?? Date()
        let components = calendar.dateComponents([.day], from: purchaseDate, to: end)
        return max(1, components.day ?? 1)
    }

    var costPerDay: Double {
        let effectivePrice: Double
        if status == "售出", let sold = soldPrice {
            effectivePrice = price - sold
        } else {
            effectivePrice = price
        }
        return effectivePrice / Double(daysUsed)
    }
}

// MARK: - 数据加载

private func loadProducts() -> [WidgetProduct] {
    let defaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier)
    guard let data = defaults?.data(forKey: "products_key") else { return [] }
    return (try? JSONDecoder().decode([WidgetProduct].self, from: data)) ?? []
}

// MARK: - 图标映射

private func iconName(for type: String) -> String {
    switch type {
    case "手机":     return "iphone"
    case "平板":    return "ipad"
    case "电脑":  return "laptopcomputer"
    case "手表":     return "applewatch"
    case "耳机": return "headphones"
    case "相机":    return "camera"
    case "游戏机":   return "gamecontroller"
    default:          return "cube"
    }
}

private func costColor(_ cost: Double) -> Color {
    switch cost {
    case 0..<5:  return .green
    case 5..<20: return .orange
    default:     return .red
    }
}

// MARK: - Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), products: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), products: loadProducts())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let entry = SimpleEntry(date: Date(), products: loadProducts())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Entry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let products: [WidgetProduct]
}

// MARK: - Widget 1: 设备列表（Medium）

struct DeviceDailyListView: View {
    var entry: Provider.Entry

    var inUseProducts: [WidgetProduct] {
        entry.products
            .filter { $0.status == "使用" }
            .sorted { $0.costPerDay > $1.costPerDay }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("使用中设备")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(inUseProducts.count) 台")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if inUseProducts.isEmpty {
                Text("暂无数据")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(inUseProducts.prefix(6)) { product in
                        HStack(spacing: 6) {
                            Image(systemName: iconName(for: product.productType))
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .frame(width: 16)

                            Text(product.name)
                                .font(.system(size: 12))
                                .lineLimit(1)

                            Spacer()

                            Text("\(product.daysUsed) 天")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            Text("¥\(product.costPerDay, specifier: "%.2f")")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(costColor(product.costPerDay))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct DeviceDailyListWidget: Widget {
    let kind: String = "DeviceDailyListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DeviceDailyListView(entry: entry)
        }
        .configurationDisplayName("设备列表")
        .description("展示使用中设备的日均成本")
        .supportedFamilies([.systemMedium])
    }
}

