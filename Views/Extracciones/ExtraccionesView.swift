import SwiftUI
import SwiftData

struct ExtraccionesView: View {
    let onAddExtraction: () -> Void

    @Query(sort: \Extraction.date, order: .reverse) private var allExtractions: [Extraction]

    // Group by calendar day
    private var groups: [(String, [Extraction])] {
        var dict: [String, [Extraction]] = [:]
        var keys: [String] = []
        for ext in allExtractions {
            let key = ext.date.relativeDayLabel
            if dict[key] == nil {
                dict[key] = []
                keys.append(key)
            }
            dict[key]!.append(ext)
        }
        return keys.map { ($0, dict[$0]!) }
    }

    private var totalMl: Int { allExtractions.reduce(0) { $0 + $1.ml } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Extracciones")
                            .font(.system(size: 34, weight: .bold))

                        // Summary card
                        HStack {
                            SummaryStat(label: "Total",   value: "\(allExtractions.count)")
                            Divider().frame(height: 32)
                            SummaryStat(label: "Cafés",   value: "\(Set(allExtractions.compactMap(\.coffee?.persistentModelID)).count)")
                            Divider().frame(height: 32)
                            SummaryStat(
                                label: "Volumen",
                                value: String(format: "%.1f", Double(totalMl) / 1000),
                                unit: "L"
                            )
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 54)
                    .padding(.bottom, 12)

                    // Day groups
                    ForEach(groups, id: \.0) { label, exts in
                        // Day header
                        HStack(alignment: .lastTextBaseline) {
                            Text(label)
                                .font(.system(size: 13, weight: .semibold))
                            Spacer()
                            Text("\(exts.count) \(exts.count == 1 ? "extracción" : "extracciones")")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.4)
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 14)
                        .padding(.bottom, 6)

                        // Rows card
                        VStack(spacing: 0) {
                            ForEach(Array(exts.enumerated()), id: \.element.persistentModelID) { idx, ext in
                                if idx > 0 { Divider().padding(.leading, 70) }
                                FeedRowView(ext: ext)
                            }
                        }
                        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 110)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Feed row

struct FeedRowView: View {
    let ext: Extraction

    var body: some View {
        HStack(spacing: 12) {
            if let coffee = ext.coffee {
                BagThumbView(coffee: coffee, size: 42, cornerRadius: 9)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(ext.coffee?.name ?? "—")
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Text(ext.date.timeLabel)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                HStack(spacing: 6) {
                    ParamPillView(value: String(format: "%.1f", ext.grind), unit: "mol")
                    Rectangle().fill(Color(.separator)).frame(width: 1, height: 10)
                    ParamPillView(value: "\(ext.ml)", unit: "ml")
                    Rectangle().fill(Color(.separator)).frame(width: 1, height: 10)
                    ParamPillView(value: "\(ext.sec)", unit: "s")
                }
                if !ext.note.isEmpty {
                    Text(ext.note)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .italic()
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Summary stat

struct SummaryStat: View {
    let label: String
    let value: String
    var unit: String = ""

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .semibold))
                    .monospacedDigit()
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
