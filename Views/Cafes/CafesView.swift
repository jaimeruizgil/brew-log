import SwiftUI
import SwiftData

struct CafesView: View {
    let cardStyle: CardStyle
    let onAddCoffee: () -> Void

    @Environment(\.modelContext) private var context
    @Query(sort: \Coffee.name) private var allCoffees: [Coffee]

    @State private var searchText     = ""
    @State private var showFilter     = false
    @State private var roastFilter    = Set<RoastLevel>()
    @State private var originFilter   = Set<String>()
    @State private var minScore: Double = 0
    @State private var selectedCoffee: Coffee?
    @State private var showDetail     = false

    private var filtered: [Coffee] {
        allCoffees.filter { c in
            let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
            let matchesSearch = q.isEmpty ||
                c.name.lowercased().contains(q) ||
                c.roaster.lowercased().contains(q) ||
                c.origin.lowercased().contains(q) ||
                c.variety.lowercased().contains(q)
            let matchesRoast  = roastFilter.isEmpty  || roastFilter.contains(c.roast)
            let matchesOrigin = originFilter.isEmpty || originFilter.contains(c.origin)
            let matchesScore  = c.score >= minScore
            return matchesSearch && matchesRoast && matchesOrigin && matchesScore
        }
    }

    private var activeFilterCount: Int {
        roastFilter.count + originFilter.count + (minScore > 0 ? 1 : 0)
    }

    private var allOrigins: [String] {
        Array(Set(allCoffees.map(\.origin))).sorted()
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .lastTextBaseline) {
                        Text("Cafés")
                            .font(.system(size: 34, weight: .bold))
                        Spacer()
                        Text("\(filtered.count) de \(allCoffees.count)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }

                    // Search + filter row
                    HStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 14))
                            TextField("Buscar por nombre, tostador, origen…", text: $searchText)
                                .font(.system(size: 15))
                            if !searchText.isEmpty {
                                Button { searchText = "" } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 38)
                        .background(Color(.systemFill), in: RoundedRectangle(cornerRadius: 12))

                        Button { showFilter = true } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 17))
                                    .frame(width: 38, height: 38)
                                    .background(
                                        activeFilterCount > 0
                                            ? Color.accentColor.opacity(0.12)
                                            : Color(.systemFill),
                                        in: RoundedRectangle(cornerRadius: 12)
                                    )
                                    .foregroundStyle(activeFilterCount > 0 ? Color.accentColor : .secondary)

                                if activeFilterCount > 0 {
                                    Text("\(activeFilterCount)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(width: 14, height: 14)
                                        .background(Color.accentColor, in: Circle())
                                        .offset(x: 2, y: -2)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 54)
                .padding(.bottom, 12)

                // List body
                if filtered.isEmpty {
                    emptyState
                } else {
                    listBody
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Coffee.self) { coffee in
                CoffeeDetailView(coffee: coffee)
            }
        }
        .sheet(isPresented: $showFilter) {
            FilterSheetView(
                roastFilter: $roastFilter,
                originFilter: $originFilter,
                minScore: $minScore,
                allOrigins: allOrigins
            )
        }
    }

    // MARK: - List variants

    @ViewBuilder
    private var listBody: some View {
        switch cardStyle {
        case .card:
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(filtered) { coffee in
                        NavigationLink(value: coffee) {
                            CoffeeCardRow(coffee: coffee)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 110)
            }

        case .compact:
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(filtered.enumerated()), id: \.element.persistentModelID) { idx, coffee in
                        NavigationLink(value: coffee) {
                            CoffeeCompactRow(coffee: coffee)
                        }
                        .buttonStyle(.plain)
                        if idx < filtered.count - 1 { Divider().padding(.leading, 68) }
                    }
                }
                .padding(.bottom, 110)
            }

        case .inset:
            ScrollView {
                LazyVStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ForEach(Array(filtered.enumerated()), id: \.element.persistentModelID) { idx, coffee in
                            NavigationLink(value: coffee) {
                                CoffeeInsetRow(coffee: coffee)
                            }
                            .buttonStyle(.plain)
                            if idx < filtered.count - 1 {
                                Divider().padding(.leading, 78)
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 110)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 4) {
            Text("Sin resultados")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(.label).opacity(0.7))
            Text("Prueba con otra búsqueda o ajusta los filtros.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
    }
}

// MARK: - Card styles

struct CoffeeCardRow: View {
    let coffee: Coffee
    var body: some View {
        HStack(spacing: 14) {
            BagThumbView(coffee: coffee, size: 62, cornerRadius: 13)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    if coffee.isOpen { OpenDotView() }
                    Text(coffee.name)
                        .font(.system(size: 17, weight: .semibold))
                        .lineLimit(1)
                }
                Text("\(coffee.roaster) · \(coffee.origin)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 10) {
                    RoastBadgeView(roast: coffee.roast)
                    ScoreDotsView(score: coffee.score)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
}

struct CoffeeInsetRow: View {
    let coffee: Coffee
    var body: some View {
        HStack(spacing: 12) {
            BagThumbView(coffee: coffee, size: 52, cornerRadius: 11)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    if coffee.isOpen { OpenDotView() }
                    Text(coffee.name)
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                }
                Text("\(coffee.roaster) · \(coffee.origin)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.bottom, 4)
                HStack(spacing: 8) {
                    RoastBadgeView(roast: coffee.roast)
                    ScoreDotsView(score: coffee.score)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .contentShape(Rectangle())
    }
}

struct CoffeeCompactRow: View {
    let coffee: Coffee
    var body: some View {
        HStack(spacing: 12) {
            BagThumbView(coffee: coffee, size: 36, cornerRadius: 8)
            HStack(spacing: 6) {
                if coffee.isOpen { OpenDotView() }
                VStack(alignment: .leading, spacing: 1) {
                    Text(coffee.name)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                    Text("\(coffee.roaster) · \(coffee.roast.shortLabel) · \(coffee.origin)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            ScoreDotsView(score: coffee.score, dotSize: 6, spacing: 3)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }
}
