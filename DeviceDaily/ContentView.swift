//
//  ContentView.swift
//  DeviceDaily
//
//  Created by 迟暮 on 2026/6/8.
//

import SwiftUI
import WidgetKit

private enum ProductSheetRoute: Identifiable {
    case add
    case edit(DigitalProduct)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let product):
            return product.id.uuidString
        }
    }
}

struct ContentView: View {
    @State private var products: [DigitalProduct] = []
    @State private var activeSheet: ProductSheetRoute? = nil

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 统计总览 + 添加按钮
            HStack(spacing: 24) {
                StatCard(
                    title: "当前持有价值",
                    value: String(format: "¥%.0f", totalValue),
                    icon: "creditcard",
                    color: .blue
                )

                StatCard(
                    title: "使用中设备",
                    value: "\(inUseCount) 台",
                    icon: "laptopcomputer",
                    color: .green
                )

                StatCard(
                    title: "当前每日总成本",
                    value: String(format: "¥%.2f", totalDailyCost),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )

                Button {
                    activeSheet = .add
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.blue)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("添加产品")
            }
            .padding()
            .background(.ultraThinMaterial)

            Divider()

            // MARK: - 列表区域
            if products.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "macbook.and.iphone")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("还没有添加任何产品")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("点击右上角的 + 添加你的第一个数码产品")
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            } else {
                ScrollView {
                    Grid(alignment: .leading, horizontalSpacing: 28, verticalSpacing: 0) {
                        // Header
                        GridRow {
                            Text("产品")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.leading)

                            Text("购入日期")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.trailing)

                            Text("状态")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.trailing)

                            Text("已用天数")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.trailing)

                            Text("日均成本")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.trailing)
                                .padding(.trailing, 22)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)

                        Divider()
                            .padding(.horizontal, 20)
                            .gridCellColumns(5)

                        // Rows
                        ForEach(products) { product in
                            GridRow {
                                // 产品信息
                                HStack(spacing: 8) {
                                    Image(systemName: product.productType.iconName)
                                        .foregroundStyle(productTypeColor(product))
                                        .frame(width: 20)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(product.name)
                                            .font(.system(size: 14, weight: .medium))
                                            .lineLimit(1)
                                            .truncationMode(.tail)

                                        HStack(spacing: 4) {
                                            if let config = product.configDisplay {
                                                Text(config)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                Text("·")
                                                    .font(.caption)
                                                    .foregroundStyle(.tertiary)
                                            }
                                            Text("¥\(product.price, specifier: "%.0f")")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .gridColumnAlignment(.leading)

                                Text(formatDateShort(product.purchaseDate))
                                    .font(.system(size: 13))
                                    .gridColumnAlignment(.trailing)

                                Text(product.statusDisplay)
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(statusColor(product).opacity(0.15))
                                    .foregroundStyle(statusColor(product))
                                    .clipShape(Capsule())
                                    .gridColumnAlignment(.trailing)

                                Text("\(product.daysUsed) 天")
                                    .font(.system(size: 13, weight: .medium))
                                    .gridColumnAlignment(.trailing)

                                HStack(spacing: 8) {
                                    Text("¥\(product.costPerDay, specifier: "%.2f")")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(costColor(product))
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(costColor(product).opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)

                                    Button {
                                        deleteProduct(product)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.secondary.opacity(0.35))
                                    }
                                    .buttonStyle(.plain)
                                    .help("删除此设备")
                                }
                                .gridColumnAlignment(.trailing)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                activeSheet = .edit(product)
                            }

                            Divider()
                                .padding(.horizontal, 20)
                                .gridCellColumns(5)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(minWidth: 700, minHeight: 340)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .add:
                ProductSheet(products: $products)
            case .edit(let product):
                ProductSheet(products: $products, existingProduct: product)
            }
        }
        .onAppear {
            loadProducts()
        }
    }

    private func loadProducts() {
        let defaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier) ?? UserDefaults.standard
        guard let data = defaults.data(forKey: "products_key") else { return }
        products = (try? JSONDecoder().decode([DigitalProduct].self, from: data)) ?? []
    }

    private func saveProducts() {
        let defaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier) ?? UserDefaults.standard
        if let data = try? JSONEncoder().encode(products) {
            defaults.set(data, forKey: "products_key")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    // MARK: - 列表辅助方法

    private func deleteProduct(_ product: DigitalProduct) {
        products.removeAll { $0.id == product.id }
        saveProducts()
    }

    private func productTypeColor(_ product: DigitalProduct) -> Color {
        switch product.productType {
        case .phone:     return .indigo
        case .tablet:    return .blue
        case .computer:  return .cyan
        case .watch:     return .orange
        case .headphone: return .pink
        case .camera:    return .gray
        case .console:   return .purple
        case .other:     return .secondary
        }
    }

    private func statusColor(_ product: DigitalProduct) -> Color {
        switch product.status {
        case .inUse:     return .blue
        case .sold:      return .green
        case .discarded: return .gray
        case .gifted:    return .pink
        case .other:     return .purple
        }
    }

    private func costColor(_ product: DigitalProduct) -> Color {
        switch product.costPerDay {
        case 0..<5:     return .green
        case 5..<20:    return .orange
        default:        return .red
        }
    }

    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: - 统计数据

    private var totalValue: Double {
        products.filter(\.isCurrentlyOwned).map(\.price).reduce(0, +)
    }

    private var inUseCount: Int {
        products.filter { $0.status == .inUse }.count
    }

    private var totalDailyCost: Double {
        products.filter { $0.status == .inUse }.map(\.costPerDay).reduce(0, +)
    }
}

// MARK: - 添加/编辑产品弹窗

struct ProductSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var products: [DigitalProduct]
    var existingProduct: DigitalProduct? = nil

    @State private var name = ""
    @State private var priceText = ""
    @State private var purchaseDate = Date()
    @State private var productType = ProductType.other
    @State private var status = ProductStatus.inUse
    @State private var endDate = Date()
    @State private var soldPriceText = ""
    @State private var customNoteText = ""
    @State private var ramText = ""
    @State private var storageText = ""

    private var isEditing: Bool { existingProduct != nil }

    private var price: Double {
        Double(priceText.replacingOccurrences(of: ",", with: "")) ?? 0
    }

    private var soldPrice: Double {
        Double(soldPriceText.replacingOccurrences(of: ",", with: "")) ?? 0
    }

    private var isValid: Bool {
        let baseValid = !name.trimmingCharacters(in: .whitespaces).isEmpty && price > 0
        if status == .sold {
            return baseValid && soldPrice >= 0
        }
        if status == .other {
            return baseValid && !customNoteText.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return baseValid
    }

    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text(isEditing ? "编辑数码产品" : "添加数码产品")
                    .font(.title3.bold())
                Spacer()
                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()

            Divider()

            // 表单
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    FormRow(label: "产品名称") {
                        TextField("例如 iPhone 16 Pro Max", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }

                    HStack(spacing: 16) {
                        FormRow(label: "购买价格") {
                            TextField("¥", text: $priceText)
                                .textFieldStyle(.roundedBorder)
                        }
                        FormRow(label: "购买日期") {
                            DatePicker("", selection: $purchaseDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                    }

                    HStack(spacing: 16) {
                        FormRow(label: "产品类型") {
                            Picker("", selection: $productType) {
                                ForEach(ProductType.allCases, id: \.self) { t in
                                    Label(t.displayName, systemImage: t.iconName).tag(t)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        FormRow(label: "使用状态") {
                            Picker("", selection: $status) {
                                ForEach(ProductStatus.allCases, id: \.self) { s in
                                    Text(s.displayName).tag(s)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }

                    // 条件输入
                    if status != .inUse {
                        FormRow(label: "结束时间") {
                            HStack(spacing: 10) {
                                DatePicker("", selection: $endDate, in: purchaseDate...Date(), displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                Text("计算天数截止到该日期")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if productType.supportsConfig {
                        HStack(spacing: 16) {
                            FormRow(label: "内存") {
                                TextField("例如 32G", text: $ramText)
                                    .textFieldStyle(.roundedBorder)
                            }
                            FormRow(label: "存储") {
                                TextField("例如 512G", text: $storageText)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if status == .sold {
                        FormRow(label: "售出金额") {
                            HStack(spacing: 10) {
                                TextField("¥", text: $soldPriceText)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(maxWidth: 140)
                                Text("日均 = (购买价 − 售出金额) ÷ 天数")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if status == .other {
                        FormRow(label: "自定义备注") {
                            TextField("将显示为状态名称", text: $customNoteText)
                                .textFieldStyle(.roundedBorder)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding()
                .animation(.easeInOut(duration: 0.2), value: productType)
                .animation(.easeInOut(duration: 0.2), value: status)
            }

            Divider()

            // 底部按钮
            HStack {
                if isEditing, let product = existingProduct {
                    Button("删除设备", role: .destructive) {
                        if let index = products.firstIndex(where: { $0.id == product.id }) {
                            products.remove(at: index)
                            let defaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier) ?? UserDefaults.standard
                            if let data = try? JSONEncoder().encode(products) {
                                defaults.set(data, forKey: "products_key")
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                        dismiss()
                    }
                }

                Spacer()

                Button("取消") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button(isEditing ? "保存修改" : "添加产品") {
                    saveProduct()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(minWidth: 520, minHeight: 360)
        .onAppear {
            if let p = existingProduct {
                name = p.name
                priceText = String(format: "%.0f", p.price)
                purchaseDate = p.purchaseDate
                productType = p.productType
                status = p.status
                if let ed = p.endDate { endDate = ed }
                if let sp = p.soldPrice { soldPriceText = String(format: "%.0f", sp) }
                customNoteText = p.customNote ?? ""
                ramText = p.ram ?? ""
                storageText = p.storage ?? ""
            }
        }
    }

    private func saveProduct() {
        let product = DigitalProduct(
            id: existingProduct?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            price: price,
            purchaseDate: purchaseDate,
            productType: productType,
            status: status,
            soldPrice: status == .sold ? soldPrice : nil,
            customNote: status == .other ? customNoteText.trimmingCharacters(in: .whitespaces) : nil,
            endDate: status != .inUse ? endDate : nil,
            ram: productType.supportsConfig ? (ramText.isEmpty ? nil : ramText.trimmingCharacters(in: .whitespaces)) : nil,
            storage: productType.supportsConfig ? (storageText.isEmpty ? nil : storageText.trimmingCharacters(in: .whitespaces)) : nil
        )

        if let existing = existingProduct, let index = products.firstIndex(where: { $0.id == existing.id }) {
            products[index] = product
        } else {
            products.append(product)
        }

        // 同步到 UserDefaults（确保 Widget 能读取）
        let defaults = UserDefaults(suiteName: AppConfig.appGroupIdentifier) ?? UserDefaults.standard
        if let data = try? JSONEncoder().encode(products) {
            defaults.set(data, forKey: "products_key")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

// MARK: - 辅助视图

/// 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

/// 标签 + 输入框 的表单行，标签统一右对齐
struct FormRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(width: 60, alignment: .trailing)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - 预览

#Preview {
    ContentView()
}
