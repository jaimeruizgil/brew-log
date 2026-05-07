import Foundation
import SwiftData

@Model
final class CoffeeLocation {
    var name: String
    var addr: String

    var coffee: Coffee?

    init(name: String, addr: String, coffee: Coffee? = nil) {
        self.name   = name
        self.addr   = addr
        self.coffee = coffee
    }
}
