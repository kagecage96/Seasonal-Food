import Foundation

class Configuration {
    var language: Language = .japanese
    static let shared = Configuration()
    
    private init() {
        
        if let languageString = NSLocale.preferredLanguages.first?.components(separatedBy: "-").first {
            language = Language(languageString: languageString)
        } else {
            language = .japanese
        }
    }
}
