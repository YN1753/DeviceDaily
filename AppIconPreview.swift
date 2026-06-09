//
//  AppIconPreview.swift
//  在 Xcode 中打开此文件，Canvas 会显示 1024x1024 的图标预览
//  右键 Canvas → Export → 选择 PNG 格式，保存为 icon_512x512@2x.png
//  然后用 sips 命令生成其他尺寸
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // 蓝绿渐变背景
            LinearGradient(
                colors: [
                    Color(red: 0.22, green: 0.55, blue: 0.75),
                    Color(red: 0.25, green: 0.70, blue: 0.65)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 白色圆形背景
            Circle()
                .fill(.white.opacity(0.92))
                .frame(width: 680, height: 680)
                .offset(y: 60)

            // 设备图标组
            IconDevices()
                .offset(y: 60)

            // 趋势线和 ¥
            TrendIcon()
                .offset(y: -200)
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 230, style: .continuous))
    }
}

struct IconDevices: View {
    let color = Color(red: 0.22, green: 0.55, blue: 0.75)

    var body: some View {
        ZStack {
            // 笔记本
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 18)
                    .frame(width: 260, height: 170)
                Rectangle()
                    .fill(color)
                    .frame(width: 290, height: 12)
                    .cornerRadius(4)
            }
            .offset(x: -130, y: -10)

            // 平板
            RoundedRectangle(cornerRadius: 12)
                .stroke(color, lineWidth: 18)
                .frame(width: 130, height: 180)
                .overlay(
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                        .offset(y: 72)
                )
                .offset(x: 120, y: -20)

            // 手机
            RoundedRectangle(cornerRadius: 16)
                .stroke(color, lineWidth: 18)
                .frame(width: 90, height: 150)
                .overlay(
                    Circle()
                        .fill(color)
                        .frame(width: 10, height: 10)
                        .offset(y: 58)
                )
                .offset(x: 0, y: 80)
        }
    }
}

struct TrendIcon: View {
    let color = Color(red: 0.22, green: 0.55, blue: 0.75)

    var body: some View {
        ZStack {
            // 折线
            Path { path in
                path.move(to: CGPoint(x: -100, y: 40))
                path.addLine(to: CGPoint(x: -30, y: -10))
                path.addLine(to: CGPoint(x: 30, y: 20))
                path.addLine(to: CGPoint(x: 100, y: -40))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round))

            // 箭头
            Path { path in
                path.move(to: CGPoint(x: 70, y: -20))
                path.addLine(to: CGPoint(x: 100, y: -40))
                path.addLine(to: CGPoint(x: 70, y: -50))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round))

            // ¥ 符号
            Text("¥")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .offset(y: -55)
        }
    }
}

// MARK: - Xcode Preview

#Preview {
    AppIconView()
        .frame(width: 1024, height: 1024)
}
