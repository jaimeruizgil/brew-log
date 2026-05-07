import SwiftUI

/// "2.4 mol" style pill used in extraction rows.
struct ParamPillView: View {
    let value: String
    let unit: String

    var body: some View {
        Text("\(Text(value).fontWeight(.semibold).foregroundStyle(Color(.label)))\(Text(" \(unit)").foregroundStyle(Color(.secondaryLabel)))")
            .font(.system(size: 12, design: .monospaced))
            .monospacedDigit()
    }
}
