import Foundation

extension Date {
    /// "6 may" (day + short Spanish month)
    var shortBrewLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "d MMM"
        return f.string(from: self).lowercased()
    }

    /// "6 de mayo de 2026"
    var longBrewLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "d 'de' MMMM 'de' yyyy"
        return f.string(from: self)
    }

    /// "6 may 2026"
    var mediumBrewLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "d MMM yyyy"
        return f.string(from: self).lowercased()
    }

    /// "Hoy", "Ayer", day name, or medium date
    var relativeDayLabel: String {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let day   = cal.startOfDay(for: self)
        let diff  = cal.dateComponents([.day], from: day, to: today).day ?? 0
        switch diff {
        case 0:  return "Hoy"
        case 1:  return "Ayer"
        case 2...6:
            let f = DateFormatter()
            f.locale = Locale(identifier: "es_ES")
            f.dateFormat = "EEEE"
            return f.string(from: self).capitalized
        default: return mediumBrewLabel
        }
    }

    /// "HH:mm"
    var timeLabel: String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: self)
    }

    /// Short month, uppercase: "MAY"
    var shortMonthLabel: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "MMM"
        return f.string(from: self).uppercased()
    }

    /// Day number
    var dayNumber: Int {
        Calendar.current.component(.day, from: self)
    }

    // MARK: - Initializers

    static func from(ymd: String, hm: String = "00:00") -> Date {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        f.locale = Locale(identifier: "es_ES")
        f.timeZone = TimeZone(identifier: "Europe/Madrid")
        return f.date(from: "\(ymd) \(hm)") ?? .now
    }
}
