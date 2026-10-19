import SwiftUI

// MARK: - Flat Design System
// Vibrant solid colors, no gradients, no shadows, clean sans-serif typography,
// simple geometric shapes, ample whitespace, soft rounded corners.

enum FlatColors {
    // Primary Palette — bold & vibrant
    static let primary = Color(red: 0.20, green: 0.76, blue: 0.46)       // Emerald green
    static let primaryDark = Color(red: 0.15, green: 0.62, blue: 0.38)
    
    // Accent Colors — saturated flat palette
    static let coral = Color(red: 0.91, green: 0.35, blue: 0.35)         // Warm red
    static let sunflower = Color(red: 0.95, green: 0.77, blue: 0.22)     // Bright yellow
    static let ocean = Color(red: 0.20, green: 0.60, blue: 0.98)         // Vivid blue
    static let amethyst = Color(red: 0.61, green: 0.35, blue: 0.91)      // Rich purple
    static let tangerine = Color(red: 0.95, green: 0.55, blue: 0.22)     // Orange
    static let rose = Color(red: 0.91, green: 0.36, blue: 0.58)          // Pink
    static let mint = Color(red: 0.22, green: 0.82, blue: 0.72)          // Teal-mint
    static let sky = Color(red: 0.35, green: 0.78, blue: 0.98)           // Light blue
    
    // Neutrals — clean flat grays
    static let background = Color(red: 0.96, green: 0.96, blue: 0.97)
    static let card = Color.white
    static let cardDark = Color(red: 0.14, green: 0.15, blue: 0.18)
    static let textPrimary = Color(red: 0.16, green: 0.17, blue: 0.21)
    static let textSecondary = Color(red: 0.55, green: 0.56, blue: 0.62)
    static let textTertiary = Color(red: 0.72, green: 0.73, blue: 0.76)
    static let divider = Color(red: 0.91, green: 0.91, blue: 0.93)
    static let inputBg = Color(red: 0.94, green: 0.94, blue: 0.96)
    
    // Semantic
    static let success = primary
    static let warning = sunflower
    static let error = coral
    static let info = ocean
}

// MARK: - Flat Typography (Sans-Serif)

enum FlatFont {
    static func title(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    
    static func heading(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    static func body(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func label(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    static func caption(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
}

// MARK: - Flat Card Modifier

struct FlatCard: ViewModifier {
    var cornerRadius: CGFloat = 12
    var padding: CGFloat = 18
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(FlatColors.card)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func flatCard(cornerRadius: CGFloat = 12, padding: CGFloat = 18) -> some View {
        modifier(FlatCard(cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: - Flat Button Styles

struct FlatPrimaryButton: ButtonStyle {
    var color: Color = FlatColors.primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FlatFont.heading(16))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(configuration.isPressed ? color.opacity(0.85) : color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct FlatSecondaryButton: ButtonStyle {
    var color: Color = FlatColors.primary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FlatFont.heading(16))
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(color.opacity(configuration.isPressed ? 0.15 : 0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct FlatIconButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

// MARK: - Flat Badge

struct FlatBadge: View {
    let text: String
    let color: Color
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(FlatFont.caption())
                .fontWeight(.semibold)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Flat Icon Circle

struct FlatIconCircle: View {
    let icon: String
    let color: Color
    var size: CGFloat = 36
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: size * 0.28))
    }
}

// MARK: - Flat Divider

struct FlatDivider: View {
    var body: some View {
        Rectangle()
            .fill(FlatColors.divider)
            .frame(height: 1)
    }
}

// MARK: - Flat Progress Bar

struct FlatProgressBar: View {
    let progress: Double
    let color: Color
    var height: CGFloat = 8
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color.opacity(0.12))
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geo.size.width * min(progress, 1.0), height: height)
            }
        }
        .frame(height: height)
    }
}
