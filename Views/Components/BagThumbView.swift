import SwiftUI

/// Tinted bag placeholder with paper-fold gradients and a two-letter roaster monogram.
struct BagThumbView: View {
    let coffee: Coffee
    var size: CGFloat = 56
    var cornerRadius: CGFloat = 12

    var body: some View {
        ZStack {
            coffee.toneColor

            // Paper-bag fold — top highlight
            LinearGradient(
                colors: [.white.opacity(0.18), .clear],
                startPoint: .top,
                endPoint: .init(x: 0.5, y: 0.38)
            )

            // Bottom shadow
            VStack {
                Spacer()
                LinearGradient(
                    colors: [.clear, .black.opacity(0.18)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: size * 0.20)
            }

            Text(coffee.monogram)
                .font(.system(size: size * 0.32, weight: .bold))
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(1)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(.black.opacity(0.08), lineWidth: 0.5)
        )
    }
}
