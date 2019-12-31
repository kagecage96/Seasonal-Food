import Foundation

class Configuration {
    var language: Language = .japanese
    static let shared = Configuration()
    
    private init() {
        
    }
}
