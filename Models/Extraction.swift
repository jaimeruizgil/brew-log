import Foundation
import SwiftData

@Model
final class Extraction {
    /// Full timestamp (date + time combined)
    var date: Date
    /// Grind setting (e.g. 2.4)
    var grind: Double
    /// Output in ml
    var ml: Int
    /// Pull time in seconds
    var sec: Int
    var note: String

    var coffee: Coffee?

    init(date: Date, grind: Double, ml: Int, sec: Int, note: String, coffee: Coffee? = nil) {
        self.date   = date
        self.grind  = grind
        self.ml     = ml
        self.sec    = sec
        self.note   = note
        self.coffee = coffee
    }

    var ratio: Double { Double(ml) / 18.0 }
    var flowRate: Double { sec > 0 ? Double(ml) / Double(sec) : 0 }
}
