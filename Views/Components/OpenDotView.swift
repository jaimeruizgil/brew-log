import SwiftUI

/// Pulsing dot indicator for "currently open" coffees.
struct OpenDotView: View {
    @State private var pulsing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.35))
                .frame(width: 8, height: 8)
                .scaleEffect(pulsing ? 2.2 : 1.0)
                .opacity(pulsing ? 0 : 0.35)

            Circle()
                .fill(Color.accentColor)
                .frame(width: 5, height: 5)
        }
        .frame(width: 8, height: 8)
        .onAppear {
            withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                pulsing = true
            }
        }
    }
}
