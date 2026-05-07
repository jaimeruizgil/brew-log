import SwiftUI

struct FilterSheetView: View {
    @Binding var roastFilter:  Set<RoastLevel>
    @Binding var originFilter: Set<String>
    @Binding var minScore:     Double
    let allOrigins: [String]

    @Environment(\.dismiss) private var dismiss

    // Local copies applied on "Aplicar"
    @State private var localRoast:  Set<RoastLevel>
    @State private var localOrigin: Set<String>
    @State private var localScore:  Double

    init(roastFilter: Binding<Set<RoastLevel>>,
         originFilter: Binding<Set<String>>,
         minScore: Binding<Double>,
         allOrigins: [String]) {
        _roastFilter  = roastFilter
        _originFilter = originFilter
        _minScore     = minScore
        self.allOrigins = allOrigins
        _localRoast   = State(initialValue: roastFilter.wrappedValue)
        _localOrigin  = State(initialValue: originFilter.wrappedValue)
        _localScore   = State(initialValue: minScore.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Roast
                    sectionHeader("Tueste")
                    HStack(spacing: 8) {
                        ForEach(RoastLevel.allCases, id: \.self) { r in
                            let on = localRoast.contains(r)
                            Button {
                                if on { localRoast.remove(r) } else { localRoast.insert(r) }
                            } label: {
                                Text(r.shortLabel)
                                    .font(.system(size: 14, weight: on ? .semibold : .medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 11)
                                    .background(
                                        on ? Color.accentColor.opacity(0.12) : Color(.systemFill),
                                        in: RoundedRectangle(cornerRadius: 12)
                                    )
                                    .foregroundStyle(on ? Color.accentColor : Color(.label))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Origin
                    sectionHeader("Origen")
                    FlowLayout(spacing: 8) {
                        ForEach(allOrigins, id: \.self) { o in
                            let on = localOrigin.contains(o)
                            Button {
                                if on { localOrigin.remove(o) } else { localOrigin.insert(o) }
                            } label: {
                                Text(o)
                                    .font(.system(size: 13, weight: on ? .semibold : .medium))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(
                                        on ? Color.accentColor.opacity(0.12) : Color(.systemFill),
                                        in: Capsule()
                                    )
                                    .foregroundStyle(on ? Color.accentColor : Color(.label))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Score
                    sectionHeader("Puntuación mínima")
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            ScoreDotsView(score: localScore, dotSize: 10, spacing: 5)
                            Text(String(format: "%.1f / 5", localScore))
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $localScore, in: 0...5, step: 0.5)
                    }
                    .padding(.horizontal, 20)

                    // Apply button
                    Button {
                        roastFilter  = localRoast
                        originFilter = localOrigin
                        minScore     = localScore
                        dismiss()
                    } label: {
                        Text("Aplicar filtros")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Restablecer") {
                        localRoast  = []
                        localOrigin = []
                        localScore  = 0
                    }
                    .foregroundStyle(Color.accentColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.6)
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 8)
    }
}

// MARK: - Simple flow layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? 0
        var origin = CGPoint.zero
        var maxY: CGFloat = 0

        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if origin.x + size.width > width, origin.x > 0 {
                origin.x = 0
                origin.y += size.height + spacing
            }
            origin.x += size.width + spacing
            maxY = max(maxY, origin.y + size.height)
        }
        return CGSize(width: width, height: maxY)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var origin = bounds.origin
        var rowHeight: CGFloat = 0

        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if origin.x + size.width > bounds.maxX, origin.x > bounds.minX {
                origin.x = bounds.minX
                origin.y += rowHeight + spacing
                rowHeight = 0
            }
            sv.place(at: origin, proposal: .unspecified)
            origin.x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
