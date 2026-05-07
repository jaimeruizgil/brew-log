import SwiftUI
import SwiftData

// MARK: - RoastLevel

enum RoastLevel: String, Codable, CaseIterable {
    case light  = "Light"
    case medium = "Medium"
    case dark   = "Dark"

    var shortLabel: String {
        switch self {
        case .light:  "Claro"
        case .medium: "Medio"
        case .dark:   "Oscuro"
        }
    }

    var fullLabel: String {
        switch self {
        case .light:  "Tueste claro"
        case .medium: "Tueste medio"
        case .dark:   "Tueste oscuro"
        }
    }

    var fills: Int {
        switch self {
        case .light:  1
        case .medium: 2
        case .dark:   3
        }
    }

    var diamondColor: Color {
        switch self {
        case .light:  Color(hex: "#C99A6E") ?? .brown
        case .medium: Color(hex: "#7A4A2B") ?? .brown
        case .dark:   Color(hex: "#3D2415") ?? .brown
        }
    }
}

// MARK: - Coffee

@Model
final class Coffee {
    var name: String
    var roaster: String
    var origin: String
    var region: String
    var variety: String
    var process: String
    var roast: RoastLevel
    var purchaseDate: Date
    var expiryDate: Date
    var price: Double
    var weight: Int
    var notes: String
    /// Score 0–5 in 0.5 steps
    var score: Double
    var isOpen: Bool
    /// Hex string, e.g. "#A8866C"
    var toneHex: String

    @Relationship(deleteRule: .cascade, inverse: \Extraction.coffee)
    var extractions: [Extraction] = []

    @Relationship(deleteRule: .cascade, inverse: \CoffeeLocation.coffee)
    var locations: [CoffeeLocation] = []

    init(
        name: String,
        roaster: String,
        origin: String,
        region: String,
        variety: String,
        process: String,
        roast: RoastLevel,
        purchaseDate: Date,
        expiryDate: Date,
        price: Double,
        weight: Int,
        notes: String,
        score: Double,
        isOpen: Bool = false,
        toneHex: String
    ) {
        self.name         = name
        self.roaster      = roaster
        self.origin       = origin
        self.region       = region
        self.variety      = variety
        self.process      = process
        self.roast        = roast
        self.purchaseDate = purchaseDate
        self.expiryDate   = expiryDate
        self.price        = price
        self.weight       = weight
        self.notes        = notes
        self.score        = score
        self.isOpen       = isOpen
        self.toneHex      = toneHex
    }

    var toneColor: Color { Color(hex: toneHex) ?? .brown }

    var monogram: String {
        roaster
            .components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }

    /// Extractions sorted newest-first
    var sortedExtractions: [Extraction] {
        extractions.sorted { $0.date > $1.date }
    }

    var avgGrind: Double? {
        guard !extractions.isEmpty else { return nil }
        return extractions.reduce(0) { $0 + $1.grind } / Double(extractions.count)
    }

    var avgMl: Double? {
        guard !extractions.isEmpty else { return nil }
        return extractions.reduce(0.0) { $0 + Double($1.ml) } / Double(extractions.count)
    }

    var avgSec: Double? {
        guard !extractions.isEmpty else { return nil }
        return extractions.reduce(0.0) { $0 + Double($1.sec) } / Double(extractions.count)
    }
}
