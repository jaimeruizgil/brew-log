import SwiftUI

/// Three progressive diamond shapes + short label, e.g. "◆◆◇ Medio".
struct RoastBadgeView: View {
    let roast: RoastLevel
    var small: Bool = true

    private var dotSize: CGFloat { small ? 5 : 6 }
    private var fontSize: CGFloat { small ? 11 : 12 }

    var body: some View {
        HStack(spacing: 5) {
            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(i < roast.fills ? roast.diamondColor : Color(.systemFill))
                        .frame(width: dotSize, height: dotSize)
                        .rotationEffect(.degrees(45))
                }
            }
            Text(roast.shortLabel)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundStyle(Color(.label).opacity(0.88))
        }
        .padding(.vertical, small ? 3 : 4)
        .padding(.leading, small ? 7 : 8)
        .padding(.trailing, small ? 8 : 10)
        .background(Color(.systemFill).opacity(0.65))
        .clipShape(Capsule())
    }
}

#Preview {
    HStack(spacing: 12) {
        RoastBadgeView(roast: .light)
        RoastBadgeView(roast: .medium)
        RoastBadgeView(roast: .dark)
    }
    .padding()
}
