import SwiftUI

extension Color {
    /// Initialize from a CSS hex string: #RGB or #RRGGBB.
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        if h.count == 3 {
            h = h.map { "\($0)\($0)" }.joined()
        }
        guard h.count == 6, let n = UInt64(h, radix: 16) else { return nil }
        let r = Double((n & 0xFF0000) >> 16) / 255
        let g = Double((n & 0x00FF00) >> 8)  / 255
        let b = Double(n & 0x0000FF)          / 255
        self.init(red: r, green: g, blue: b)
    }
}
