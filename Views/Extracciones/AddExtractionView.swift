import SwiftUI
import SwiftData

struct AddExtractionView: View {
    var preselectedCoffee: Coffee? = nil

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss
    @Query(sort: \Coffee.name)   private var allCoffees: [Coffee]

    @State private var selectedCoffee: Coffee?
    @State private var grind:  Double = 2.5
    @State private var ml:     Double = 36
    @State private var sec:    Double = 28
    @State private var note:   String = ""
    @State private var date:   Date   = .now

    private var ratio:    String { String(format: "1 : %.1f", ml / 18.0) }
    private var flowRate: String { String(format: "%.2f ml/s", sec > 0 ? ml / sec : 0) }

    var body: some View {
        NavigationStack {
            Form {
                // Coffee selector
                Section {
                    Picker("Café", selection: $selectedCoffee) {
                        Text("Seleccionar…").tag(Coffee?.none)
                        ForEach(allCoffees) { c in
                            HStack {
                                Text(c.name)
                                Text(c.roaster).foregroundStyle(.secondary)
                            }
                            .tag(Optional(c))
                        }
                    }

                    if let c = selectedCoffee {
                        HStack(spacing: 10) {
                            BagThumbView(coffee: c, size: 40, cornerRadius: 9)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(c.name)
                                    .font(.system(size: 14, weight: .semibold))
                                    .lineLimit(1)
                                Text(c.roaster)
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                // Stepper trio
                Section {
                    HStack(spacing: 10) {
                        BigStepper(label: "Molienda", value: $grind, step: 0.1) { String(format: "%.1f", grind) }
                        BigStepper(label: "Salida",   value: $ml,    step: 1,   unit: "ml") { "\(Int(ml))" }
                        BigStepper(label: "Tiempo",   value: $sec,   step: 1,   unit: "s")  { "\(Int(sec))" }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))

                    // Ratio bar
                    HStack {
                        Text("Ratio")
                            .font(.system(size: 13, weight: .semibold))
                        Spacer()
                        Text(ratio)
                            .font(.system(size: 13, weight: .semibold))
                            .monospacedDigit()
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(flowRate)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.accentColor.opacity(0.65))
                            .monospacedDigit()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 8, trailing: 0))
                }

                // Date
                Section("Cuándo") {
                    DatePicker("Fecha y hora", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                // Note
                Section("Nota rápida (opcional)") {
                    TextEditor(text: $note)
                        .frame(minHeight: 70)
                        .overlay(alignment: .topLeading) {
                            if note.isEmpty {
                                Text("Subextraído, prueba subir un punto…")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
            .navigationTitle("Nueva extracción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.accentColor)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") { save() }
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                selectedCoffee = preselectedCoffee ?? allCoffees.first(where: \.isOpen) ?? allCoffees.first
            }
        }
    }

    private func save() {
        guard let coffee = selectedCoffee else { return }
        let ext = Extraction(
            date: date,
            grind: grind,
            ml: Int(ml),
            sec: Int(sec),
            note: note,
            coffee: coffee
        )
        context.insert(ext)
        coffee.extractions.append(ext)
        dismiss()
    }
}

// MARK: - Big stepper

struct BigStepper: View {
    let label: String
    @Binding var value: Double
    let step: Double
    var unit: String = ""
    let display: () -> String

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .lineLimit(1)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(display())
                    .font(.system(size: 30, weight: .bold))
                    .monospacedDigit()
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 2)
                }
            }
            .frame(minHeight: 36)

            HStack(spacing: 6) {
                stepperButton("−") {
                    value = max(0, (value - step * 10).rounded() / 10)
                }
                stepperButton("+") {
                    value = ((value + step) * 10).rounded() / 10
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func stepperButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 17, weight: .medium))
                .frame(width: 36, height: 30)
                .background(Color(.systemFill), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}
