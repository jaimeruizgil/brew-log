import SwiftUI
import SwiftData

struct AddEditCoffeeView: View {
    var coffee: Coffee? = nil

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss

    // Form state
    @State private var name:         String     = ""
    @State private var roaster:      String     = ""
    @State private var origin:       String     = ""
    @State private var region:       String     = ""
    @State private var variety:      String     = ""
    @State private var process:      String     = ""
    @State private var roast:        RoastLevel = .medium
    @State private var purchaseDate: Date       = .now
    @State private var expiryDate:   Date       = Calendar.current.date(byAdding: .month, value: 3, to: .now) ?? .now
    @State private var priceText:    String     = ""
    @State private var weightText:   String     = "250"
    @State private var notes:        String     = ""
    @State private var score:        Double     = 3.0
    @State private var toneHex:      String     = "#7A4A2B"
    @State private var isOpen:       Bool       = false

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && !roaster.trimmingCharacters(in: .whitespaces).isEmpty }
    private var isEditing: Bool { coffee != nil }

    var body: some View {
        NavigationStack {
            Form {
                // Photo / tone color picker (placeholder)
                Section {
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(hex: toneHex) ?? .brown)
                                .frame(width: 110, height: 110)
                            LinearGradient(colors: [.white.opacity(0.18), .clear], startPoint: .top, endPoint: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .frame(width: 110, height: 110)
                            VStack(spacing: 4) {
                                Image(systemName: "camera")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                Text("FOTO")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .tracking(0.2)
                            }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init())

                    ColorPicker("Color del envase", selection: Binding(
                        get: { Color(hex: toneHex) ?? .brown },
                        set: { newColor in
                            // Convert UIColor to hex
                            let ui = UIColor(newColor)
                            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
                            ui.getRed(&r, green: &g, blue: &b, alpha: nil)
                            toneHex = String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
                        }
                    ))
                }

                // Info
                Section("Información") {
                    LabeledContent("Nombre") {
                        TextField("Finca El Paraíso", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Tostador") {
                        TextField("Right Side Coffee", text: $roaster)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Origen") {
                        TextField("Colombia", text: $origin)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Región") {
                        TextField("Cauca", text: $region)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Variedad") {
                        TextField("Castillo", text: $variety)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Proceso") {
                        TextField("Lavado anaeróbico", text: $process)
                            .multilineTextAlignment(.trailing)
                    }
                }

                // Roast
                Section("Tueste") {
                    Picker("Tueste", selection: $roast) {
                        ForEach(RoastLevel.allCases, id: \.self) { r in
                            Text(r.shortLabel).tag(r)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                }

                // Purchase
                Section("Compra") {
                    DatePicker("Fecha de compra", selection: $purchaseDate, displayedComponents: .date)
                    DatePicker("Caducidad",       selection: $expiryDate,   displayedComponents: .date)
                    LabeledContent("Precio (€)") {
                        TextField("18,50", text: $priceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Peso (g)") {
                        TextField("250", text: $weightText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Toggle("En uso", isOn: $isOpen)
                }

                // Tasting
                Section("Cata") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Puntuación")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.4)
                            Spacer()
                            Text(String(format: "%.1f / 5", score))
                                .font(.system(size: 14, weight: .semibold))
                                .monospacedDigit()
                        }
                        ScoreDotsView(score: score, dotSize: 11, spacing: 6)
                        Slider(value: $score, in: 0...5, step: 0.5)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(isEditing ? "Editar café" : "Nuevo café")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.accentColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") { save() }
                        .foregroundStyle(canSave ? Color.accentColor : .secondary)
                        .disabled(!canSave)
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear { loadFromCoffee() }
    }

    // MARK: - Helpers

    private func loadFromCoffee() {
        guard let c = coffee else { return }
        name         = c.name
        roaster      = c.roaster
        origin       = c.origin
        region       = c.region
        variety      = c.variety
        process      = c.process
        roast        = c.roast
        purchaseDate = c.purchaseDate
        expiryDate   = c.expiryDate
        priceText    = String(format: "%.2f", c.price)
        weightText   = "\(c.weight)"
        notes        = c.notes
        score        = c.score
        toneHex      = c.toneHex
        isOpen       = c.isOpen
    }

    private func save() {
        let price  = Double(priceText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let weight = Int(weightText) ?? 250

        if let c = coffee {
            c.name         = name.trimmingCharacters(in: .whitespaces)
            c.roaster      = roaster.trimmingCharacters(in: .whitespaces)
            c.origin       = origin
            c.region       = region
            c.variety      = variety
            c.process      = process
            c.roast        = roast
            c.purchaseDate = purchaseDate
            c.expiryDate   = expiryDate
            c.price        = price
            c.weight       = weight
            c.notes        = notes
            c.score        = score
            c.toneHex      = toneHex
            c.isOpen       = isOpen
        } else {
            let newCoffee = Coffee(
                name: name.trimmingCharacters(in: .whitespaces),
                roaster: roaster.trimmingCharacters(in: .whitespaces),
                origin: origin, region: region, variety: variety,
                process: process, roast: roast,
                purchaseDate: purchaseDate, expiryDate: expiryDate,
                price: price, weight: weight,
                notes: notes, score: score, isOpen: isOpen, toneHex: toneHex
            )
            context.insert(newCoffee)
        }
        dismiss()
    }
}
