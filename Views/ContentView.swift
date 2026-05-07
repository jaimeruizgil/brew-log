import SwiftUI
import SwiftData

// MARK: - Accent & Card style preferences

enum AccentOption: String, CaseIterable {
    case crema     = "#A87750"
    case salvia    = "#6B8B6E"
    case terracota = "#B5573A"
    case tinta     = "#1F1F1F"

    var label: String {
        switch self {
        case .crema:     "Crema cálida"
        case .salvia:    "Salvia"
        case .terracota: "Terracota"
        case .tinta:     "Tinta"
        }
    }

    var color: Color { Color(hex: rawValue) ?? .primary }
}

enum CardStyle: String, CaseIterable {
    case inset   = "Lista"
    case card    = "Tarjeta"
    case compact = "Compacto"
}

// MARK: - ContentView

struct ContentView: View {
    @AppStorage("accentHex")   private var accentHex   = AccentOption.crema.rawValue
    @AppStorage("cardStyle")   private var cardStyleRaw = CardStyle.card.rawValue
    @AppStorage("fontScale")   private var fontScale: Double = 1.0
    @AppStorage("boldFont")    private var boldFont: Bool = false

    @State private var selectedTab: AppTab = .cafes
    @State private var showAddMenu        = false
    @State private var showAddCoffee      = false
    @State private var showAddExtraction  = false

    private var accent: Color { Color(hex: accentHex) ?? .brown }
    private var cardStyle: CardStyle { CardStyle(rawValue: cardStyleRaw) ?? .card }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .cafes:
                    CafesView(
                        cardStyle: cardStyle,
                        onAddCoffee: { showAddCoffee = true }
                    )
                case .extracciones:
                    ExtraccionesView(
                        onAddExtraction: { showAddExtraction = true }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BrewTabBar(
                selectedTab: $selectedTab,
                onAdd: { showAddMenu = true }
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .tint(accent)
        .environment(\.brewFontScale, fontScale)
        .environment(\.brewBoldFont, boldFont)
        .sheet(isPresented: $showAddCoffee) {
            AddEditCoffeeView()
        }
        .sheet(isPresented: $showAddExtraction) {
            AddExtractionView()
        }
        .overlay {
            if showAddMenu {
                AddMenuOverlay(
                    onClose: { showAddMenu = false },
                    onNewCoffee: { showAddMenu = false; showAddCoffee = true },
                    onNewExtraction: { showAddMenu = false; showAddExtraction = true }
                )
            }
        }
    }
}

// MARK: - Tab enum

enum AppTab { case cafes, extracciones }

// MARK: - Custom tab bar

struct BrewTabBar: View {
    @Binding var selectedTab: AppTab
    let onAdd: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            BrewTabItem(
                label: "Cafés",
                systemImage: "cup.and.saucer",
                isActive: selectedTab == .cafes
            ) { selectedTab = .cafes }

            // Centre + button
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.accentColor)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.16), radius: 12, y: 4)
            }
            .offset(y: -12)
            .padding(.horizontal, 6)

            BrewTabItem(
                label: "Extracciones",
                systemImage: "drop",
                isActive: selectedTab == .extracciones
            ) { selectedTab = .extracciones }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
        .padding(.bottom, 30)
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

struct BrewTabItem: View {
    let label: String
    let systemImage: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .medium))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(isActive ? Color.accentColor : Color(.secondaryLabel))
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add menu overlay

struct AddMenuOverlay: View {
    let onClose: () -> Void
    let onNewCoffee: () -> Void
    let onNewExtraction: () -> Void

    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture(perform: onClose)
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        AddMenuItem(
                            systemImage: "cup.and.saucer",
                            label: "Nuevo café",
                            subtitle: "Añade un nuevo grano a tu colección",
                            action: onNewCoffee
                        )
                        Divider()
                        AddMenuItem(
                            systemImage: "drop",
                            label: "Nueva extracción",
                            subtitle: "Registra una preparación rápida",
                            action: onNewExtraction,
                            isLast: true
                        )
                    }
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)

                    Button("Cancelar", action: onClose)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal, 8)
                        .padding(.bottom, 30)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .animation(.spring(duration: 0.28), value: true)
    }
}

struct AddMenuItem: View {
    let systemImage: String
    let label: String
    let subtitle: String
    let action: () -> Void
    var isLast: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 36, height: 36)
                    .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(.label))
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.secondaryLabel))
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Environment keys

private struct FontScaleKey: EnvironmentKey { static let defaultValue: Double = 1.0 }
private struct BoldFontKey:  EnvironmentKey { static let defaultValue: Bool = false }

extension EnvironmentValues {
    var brewFontScale: Double {
        get { self[FontScaleKey.self] }
        set { self[FontScaleKey.self] = newValue }
    }
    var brewBoldFont: Bool {
        get { self[BoldFontKey.self] }
        set { self[BoldFontKey.self] = newValue }
    }
}
