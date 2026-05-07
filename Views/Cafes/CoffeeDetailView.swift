import SwiftUI
import MapKit

struct CoffeeDetailView: View {
    let coffee: Coffee

    @State private var showEdit       = false
    @State private var showExtraction = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Hero — bag + name block
                HStack(alignment: .top, spacing: 16) {
                    BagThumbView(coffee: coffee, size: 108, cornerRadius: 18)

                    VStack(alignment: .leading, spacing: 0) {
                        if coffee.isOpen {
                            HStack(spacing: 6) {
                                OpenDotView()
                                Text("EN USO")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.accentColor)
                                    .tracking(0.2)
                            }
                            .padding(.vertical, 3)
                            .padding(.leading, 8)
                            .padding(.trailing, 9)
                            .background(Color.accentColor.opacity(0.12), in: Capsule())
                            .padding(.bottom, 8)
                        }

                        Text(coffee.name)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(Color(.label))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(coffee.roaster)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)

                        RoastBadgeView(roast: coffee.roast, small: false)
                            .padding(.top, 10)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // Score block
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tu puntuación")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.6)
                        ScoreDotsView(score: coffee.score, dotSize: 11, spacing: 5)
                    }
                    Spacer()
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(String(format: "%.1f", coffee.score))
                            .font(.system(size: 32, weight: .semibold))
                            .monospacedDigit()
                        Text("/ 5")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                // Tasting notes
                sectionLabel("Notas de cata")
                Text(coffee.notes)
                    .font(.system(size: 15))
                    .lineSpacing(4)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                // Specs
                sectionLabel("Detalles")
                VStack(spacing: 0) {
                    SpecRow(label: "Origen",   value: "\(coffee.origin) · \(coffee.region)")
                    SpecRow(label: "Variedad", value: coffee.variety)
                    SpecRow(label: "Proceso",  value: coffee.process)
                    SpecRow(label: "Comprado", value: coffee.purchaseDate.longBrewLabel)
                    SpecRow(label: "Caduca",   value: coffee.expiryDate.longBrewLabel)
                    SpecRow(label: "Peso",     value: "\(coffee.weight) g")
                    SpecRow(label: "Precio",   value: String(format: "%.2f €", coffee.price), isLast: true)
                }
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

                // Locations
                if !coffee.locations.isEmpty {
                    sectionLabel("Dónde lo compras")
                    VStack(spacing: 0) {
                        LocationMapView(address: coffee.locations.first?.addr)
                            .frame(height: 130)
                            .clipped()
                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 16))

                        ForEach(Array(coffee.locations.enumerated()), id: \.element.persistentModelID) { idx, loc in
                            if idx > 0 { Divider().padding(.leading, 56) }
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color.accentColor)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(loc.name)
                                        .font(.system(size: 15, weight: .semibold))
                                    Text(loc.addr)
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }

                // Extractions header
                HStack(alignment: .lastTextBaseline) {
                    Text("EXTRACCIONES · \(coffee.sortedExtractions.count)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .tracking(0.6)
                    Spacer()
                    Button("+ NUEVA") { showExtraction = true }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                        .tracking(0.2)
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)
                .padding(.bottom, 8)

                if !coffee.sortedExtractions.isEmpty {
                    // Averages
                    HStack {
                        StatCell(label: "Molienda", value: coffee.avgGrind.map { String(format: "%.1f", $0) } ?? "—")
                        Divider().frame(height: 32)
                        StatCell(label: "Salida",   value: coffee.avgMl.map { String(format: "%.0f", $0) } ?? "—", unit: "ml")
                        Divider().frame(height: 32)
                        StatCell(label: "Tiempo",   value: coffee.avgSec.map { String(format: "%.0f", $0) } ?? "—", unit: "s")
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)

                    // Recent extractions
                    VStack(spacing: 0) {
                        ForEach(Array(coffee.sortedExtractions.prefix(8).enumerated()), id: \.element.persistentModelID) { idx, ext in
                            if idx > 0 { Divider().padding(.leading, 60) }
                            ExtractionDetailRow(ext: ext)
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 16)
                }

                Spacer(minLength: 30)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(coffee.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Editar") { showEdit = true }
                    .foregroundStyle(Color.accentColor)
            }
        }
        .sheet(isPresented: $showEdit) {
            AddEditCoffeeView(coffee: coffee)
        }
        .sheet(isPresented: $showExtraction) {
            AddExtractionView(preselectedCoffee: coffee)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
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

// MARK: - Supporting cells

struct SpecRow: View {
    let label: String
    let value: String
    var isLast: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .overlay(alignment: .bottom) {
            if !isLast { Divider().padding(.leading, 16) }
        }
    }
}

struct StatCell: View {
    let label: String
    let value: String
    var unit: String = ""

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .semibold))
                    .monospacedDigit()
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExtractionDetailRow: View {
    let ext: Extraction

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(spacing: 2) {
                Text("\(ext.date.dayNumber)")
                    .font(.system(size: 17, weight: .semibold))
                    .monospacedDigit()
                Text(ext.date.shortMonthLabel)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.4)
            }
            .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    ParamPillView(value: String(format: "%.1f", ext.grind), unit: "mol")
                    ParamPillView(value: "\(ext.ml)", unit: "ml")
                    ParamPillView(value: "\(ext.sec)", unit: "s")
                }
                if !ext.note.isEmpty {
                    Text(ext.note)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .italic()
                        .lineLimit(2)
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Map placeholder (geocodes lazily)

struct LocationMapView: View {
    let address: String?

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038), // Madrid default
        span:   MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    )
    @State private var pin: CLLocationCoordinate2D?

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: pin.map { [AnnotationItem(coord: $0)] } ?? []) { item in
            MapMarker(coordinate: item.coord, tint: .accentColor)
        }
        .disabled(true)
        .task(id: address) {
            guard let addr = address else { return }
            if let loc = try? await CLGeocoder().geocodeAddressString(addr).first?.location {
                pin    = loc.coordinate
                region = MKCoordinateRegion(center: loc.coordinate, span: region.span)
            }
        }
    }

    private struct AnnotationItem: Identifiable {
        let id = UUID()
        let coord: CLLocationCoordinate2D
    }
}
