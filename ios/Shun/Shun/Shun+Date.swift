import Foundation
import UIKit

extension Date {
    enum SymbolType {
        case `default`
        case standalone
        case veryShort
        case short
        case shortStandalone
        case veryShortStandalone
        case custom(symbols: [String])
    }
    
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale   = Locale(identifier: Configuration.shared.language.localeIdentifer)
        return calendar
    }
     
    var monthIndex: Int {
        return calendar.component(.month, from: self) - 1
    }
     
    func monthSymbols(_ type: SymbolType = .`default`, locale: Locale? = nil) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = calendar.locale
        
        switch type {
        case .`default`:           return formatter.monthSymbols
        case .standalone:          return formatter.standaloneMonthSymbols
        case .veryShort:           return formatter.veryShortMonthSymbols
        case .short:               return formatter.shortMonthSymbols
        case .shortStandalone:     return formatter.shortStandaloneMonthSymbols
        case .veryShortStandalone: return formatter.veryShortStandaloneMonthSymbols
        case let .custom(symbols): return symbols
        }
    }
     
    func monthSymbol(_ type: SymbolType = .short, locale: Locale? = nil) -> String {
        return monthSymbols(type, locale: locale)[monthIndex]
    }
}
