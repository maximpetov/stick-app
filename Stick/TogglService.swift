import Foundation

struct TimeEntry: Codable {
    let id: Int
    let duration: Int  // negative = running timer
    let start: String
}

enum TogglError: LocalizedError {
    case unauthorized
    case apiError(Int)

    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Invalid API token"
        case .apiError(let code): return "API error: \(code)"
        }
    }
}

struct MonthRange {
    let start: Date
    let end: Date
    let daysInMonth: Int
    let dayOfMonth: Int
    let monthName: String
}

func currentMonthRange() -> MonthRange {
    let calendar = Calendar.current
    let now = Date()
    let comps = calendar.dateComponents([.year, .month], from: now)

    let startOfMonth = calendar.date(from: comps)!
    var nextComps = DateComponents()
    nextComps.year = comps.year
    nextComps.month = comps.month! + 1
    let startOfNext = calendar.date(from: nextComps)!

    let daysInMonth = calendar.range(of: .day, in: .month, for: now)!.count
    let dayOfMonth = calendar.component(.day, from: now)

    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US")
    formatter.dateFormat = "MMMM yyyy"
    let monthName = formatter.string(from: now)

    return MonthRange(
        start: startOfMonth,
        end: startOfNext,
        daysInMonth: daysInMonth,
        dayOfMonth: dayOfMonth,
        monthName: monthName
    )
}

func fetchEntries(token: String) async throws -> [TimeEntry] {
    let range = currentMonthRange()
    let iso = ISO8601DateFormatter()
    let startStr = iso.string(from: range.start)
    let endStr = iso.string(from: range.end)

    guard let url = URL(string: "https://api.track.toggl.com/api/v9/me/time_entries?start_date=\(startStr)&end_date=\(endStr)") else {
        throw TogglError.apiError(0)
    }

    var request = URLRequest(url: url)
    let credentials = "\(token):api_token"
    let base64 = Data(credentials.utf8).base64EncodedString()
    request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let http = response as? HTTPURLResponse else {
        throw TogglError.apiError(0)
    }
    if http.statusCode == 401 || http.statusCode == 403 {
        throw TogglError.unauthorized
    }
    if http.statusCode != 200 {
        throw TogglError.apiError(http.statusCode)
    }

    return try JSONDecoder().decode([TimeEntry].self, from: data)
}

func totalSeconds(from entries: [TimeEntry]) -> Double {
    let now = Date().timeIntervalSince1970
    return entries.reduce(0.0) { acc, entry in
        let d = entry.duration < 0
            ? now + Double(entry.duration)
            : Double(entry.duration)
        return acc + d
    }
}

func formatHours(_ seconds: Double) -> String {
    let h = Int(seconds / 3600)
    let m = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
    return "\(h)h \(String(format: "%02d", m))m"
}

func formatMoney(_ amount: Double, currency: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    formatter.locale = Locale(identifier: "en_US")
    formatter.maximumFractionDigits = 0
    formatter.minimumFractionDigits = 0
    return formatter.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
}
