import Foundation
import SwiftData

/// Inserts the prototype's 10 coffees and 31 extractions on first launch.
/// Safe to call on every app start — checks for existing data first.
enum SampleData {
    @MainActor
    static func insertIfNeeded(into context: ModelContext) async {
        let existing = try? context.fetchCount(FetchDescriptor<Coffee>())
        guard (existing ?? 0) == 0 else { return }

        let coffees = makeCoffees()
        for c in coffees { context.insert(c) }

        let extractions = makeExtractions(coffees: coffees)
        for e in extractions { context.insert(e) }

        try? context.save()
    }

    // MARK: - Coffees

    private static func makeCoffees() -> [Coffee] {
        let data: [(String, String, String, String, String, String, RoastLevel, String, String, Double, Int, String, Double, Bool, String, [(String, String)])] = [
            ("Finca El Paraíso",  "Right Side Coffee", "Colombia",    "Cauca",          "Castillo",   "Lavado anaeróbico", .light,  "2026-04-22", "2026-07-22", 18.50, 250, "Lichi, melocotón blanco, jazmín. Acidez vibrante, cuerpo sedoso. Sorprende en filtro y aguanta bien en espresso si subes la dosis.", 4.5, true,  "#A8866C", [("Tienda Right Side", "Calle de Espíritu Santo 21, Madrid")]),
            ("Mormora",           "Nomad Coffee",      "Etiopía",     "Guji",           "Heirloom",   "Natural",           .light,  "2026-04-10", "2026-07-10", 15.00, 250, "Fresa madura, arándano, chocolate con leche en el final. Muy expresivo.",                                                           4.0, false, "#8E5A3C", [("Nomad Passatge Sert", "Passatge Sert 12, Barcelona")]),
            ("La Esperanza",      "Toma Café",         "Guatemala",   "Huehuetenango",  "Bourbon",    "Lavado",            .medium, "2026-04-02", "2026-07-02", 14.00, 250, "Caramelo, almendra tostada, ciruela. Cuerpo redondo, muy versátil con leche.",                                                       3.5, false, "#6B4226", [("Toma Olavide", "Plaza de Olavide 4, Madrid"), ("Toma Palma", "Calle de la Palma 49, Madrid")]),
            ("Yirgacheffe Konga", "Hola Coffee",       "Etiopía",     "Yirgacheffe",    "Heirloom",   "Lavado",            .light,  "2026-03-28", "2026-06-28", 16.50, 250, "Bergamota, té negro, limón Meyer. Final largo y limpio.",                                                                              4.5, false, "#A07050", [("Hola Dr. Fourquet", "Calle Doctor Fourquet 33, Madrid")]),
            ("Las Margaritas",    "Syra Coffee",       "Colombia",    "Tolima",         "Pink Bourbon","Honey",            .medium, "2026-03-15", "2026-06-15", 17.00, 250, "Mango, papaya, panela. Dulzor pronunciado, acidez cítrica equilibrada.",                                                               4.0, false, "#7C4A2F", [("Syra Bailèn", "Carrer de Bailèn 70, Barcelona")]),
            ("Sumatra Mandheling","Mistral Coffee",    "Indonesia",   "Aceh",           "Tim Tim",    "Wet hulled",        .dark,   "2026-03-08", "2026-06-08", 13.00, 250, "Tabaco, cedro, cacao oscuro. Cuerpo denso, baja acidez. Perfecto para mañana fría.",                                                   3.0, false, "#3D2415", [("Mistral Roastery", "Calle Feria 24, Sevilla")]),
            ("Geisha Don Pepe",   "Nomad Coffee",      "Panamá",      "Boquete",        "Geisha",     "Lavado",            .light,  "2026-02-20", "2026-05-20", 32.00, 150, "Jazmín intenso, melocotón, miel. Una taza memorable. Reservar para ocasiones especiales.",                                             5.0, false, "#B89070", [("Nomad Passatge Sert", "Passatge Sert 12, Barcelona")]),
            ("Kii AA",            "Right Side Coffee", "Kenia",       "Kirinyaga",      "SL28 / SL34","Lavado",            .medium, "2026-02-12", "2026-05-12", 19.00, 250, "Grosella negra, tomate cherry, azúcar moreno. Acidez punzante muy característica.",                                                     4.5, false, "#8B5A3C", [("Tienda Right Side", "Calle de Espíritu Santo 21, Madrid")]),
            ("Brasil Cerrado",    "La Cafetera Roja",  "Brasil",      "Minas Gerais",   "Catuaí",     "Natural",           .medium, "2026-01-30", "2026-04-30", 11.50, 250, "Avellana, chocolate con leche, plátano maduro. Confortable, bajo en acidez.",                                                          3.0, false, "#5A3520", [("La Cafetera Roja", "Calle Sangre 9, Valencia")]),
            ("Costa Rica Tarrazú","Toma Café",         "Costa Rica",  "Tarrazú",        "Caturra",    "Honey",             .medium, "2026-01-15", "2026-04-15", 15.50, 250, "Manzana roja, miel, nuez. Equilibrado, dulzor sostenido.",                                                                             3.5, false, "#7A4A2B", [("Toma Olavide", "Plaza de Olavide 4, Madrid")]),
        ]

        return data.map { row in
            let coffee = Coffee(
                name: row.0, roaster: row.1, origin: row.2, region: row.3,
                variety: row.4, process: row.5, roast: row.6,
                purchaseDate: .from(ymd: row.7),
                expiryDate:   .from(ymd: row.8),
                price: row.9, weight: row.10,
                notes: row.11, score: row.12,
                isOpen: row.13, toneHex: row.14
            )
            for loc in row.15 {
                let l = CoffeeLocation(name: loc.0, addr: loc.1, coffee: coffee)
                coffee.locations.append(l)
            }
            return coffee
        }
    }

    // MARK: - Extractions
    // (coffeeId index, date, time, grind, ml, sec, note)

    private static func makeExtractions(coffees: [Coffee]) -> [Extraction] {
        let raw: [(Int, String, String, Double, Int, Int, String)] = [
            (0, "2026-05-06", "08:14", 2.4, 36, 28, "Punto. Final de jazmín muy claro."),
            (0, "2026-05-05", "08:21", 2.5, 38, 29, ""),
            (0, "2026-05-04", "08:18", 2.3, 35, 26, "Algo subextraído, cierra rápido."),
            (0, "2026-05-03", "17:42", 2.4, 36, 27, ""),
            (0, "2026-05-02", "08:30", 2.5, 40, 31, "Más cuerpo con leche."),
            (0, "2026-05-01", "09:02", 2.4, 36, 28, ""),
            (0, "2026-04-30", "08:11", 2.6, 38, 30, "Bajé un punto la temperatura."),
            (0, "2026-04-29", "08:17", 2.5, 37, 29, ""),
            (1, "2026-04-28", "08:25", 2.2, 34, 26, "Notas de fresa muy presentes."),
            (1, "2026-04-27", "08:19", 2.3, 36, 28, ""),
            (1, "2026-04-26", "17:50", 2.2, 35, 27, ""),
            (1, "2026-04-25", "08:13", 2.4, 38, 30, "Probando molienda más gruesa."),
            (2, "2026-04-24", "08:08", 2.6, 36, 27, ""),
            (2, "2026-04-23", "17:34", 2.7, 38, 29, "Cappuccino — espectacular."),
            (2, "2026-04-22", "08:16", 2.6, 37, 28, ""),
            (3, "2026-04-15", "08:22", 2.3, 36, 28, "Bergamota muy clara."),
            (3, "2026-04-14", "08:09", 2.4, 38, 30, ""),
            (3, "2026-04-13", "08:18", 2.3, 35, 27, ""),
            (4, "2026-04-08", "08:12", 2.5, 38, 29, ""),
            (4, "2026-04-07", "17:48", 2.5, 37, 28, "Mango clarísimo en el final."),
            (5, "2026-04-02", "08:30", 3.0, 36, 26, "Cuerpo denso, perfecto frío fuera."),
            (5, "2026-04-01", "08:24", 3.1, 38, 28, ""),
            (5, "2026-03-31", "08:11", 3.0, 36, 27, ""),
            (6, "2026-03-15", "11:05", 2.2, 32, 25, "Reservado fin de semana. Increíble."),
            (6, "2026-03-08", "11:30", 2.3, 34, 27, ""),
            (7, "2026-03-05", "08:15", 2.5, 38, 30, "Grosella muy intensa hoy."),
            (7, "2026-03-03", "08:22", 2.6, 36, 28, ""),
            (8, "2026-02-26", "08:18", 2.8, 40, 30, ""),
            (8, "2026-02-22", "17:40", 2.8, 38, 29, "Latte estupendo."),
            (9, "2026-02-15", "08:20", 2.7, 38, 29, ""),
            (9, "2026-02-10", "08:11", 2.6, 36, 28, "Equilibrado."),
        ]

        return raw.map { row in
            let coffee = coffees[row.0]
            let ext = Extraction(
                date:  .from(ymd: row.1, hm: row.2),
                grind: row.3,
                ml:    row.4,
                sec:   row.5,
                note:  row.6,
                coffee: coffee
            )
            coffee.extractions.append(ext)
            return ext
        }
    }
}
