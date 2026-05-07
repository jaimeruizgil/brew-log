import SwiftUI

/// Five dots (●●●●○) representing a 0–5 score with 0.5-step half-fill.
struct ScoreDotsView: View {
    let score: Double
    var dotSize: CGFloat = 8
    var spacing: CGFloat = 4

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<5, id: \.self) { i in
                let fill = score - Double(i)
                Circle()
                    .fill(dotGradient(for: fill))
                    .frame(width: dotSize, height: dotSize)
            }
        }
    }

    private func dotGradient(for fill: Double) -> AnyShapeStyle {
        if fill >= 1.0 {
            return AnyShapeStyle(Color.accentColor)
        } else if fill >= 0.5 {
            return AnyShapeStyle(LinearGradient(
                stops: [
                    .init(color: .accentColor,          location: 0.5),
                    .init(color: Color(.systemFill),    location: 0.5),
                ],
                startPoint: .leading, endPoint: .trailing
            ))
        } else {
            return AnyShapeStyle(Color(.systemFill))
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        ScoreDotsView(score: 0)
        ScoreDotsView(score: 2.5)
        ScoreDotsView(score: 4.5)
        ScoreDotsView(score: 5)
    }
    .padding()
}
