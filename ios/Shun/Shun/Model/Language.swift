enum Language {
    case japanese
    case english
    
    init(languageString: String) {
        switch languageString {
        case "jp":
            self = .japanese
        case "en":
            self = .english
        default:
            self = .japanese
        }
    }
    
     var name: String {
        switch self {
        case .japanese:
            return "japanese"
        case .english:
            return "english"
        }
    }
    
    var localeString: String {
        switch self {
        case .japanese:
            return "jp"
        case .english:
            return "en"
        }
    }
    
    var localeIdentifer: String {
        switch self {
        case .japanese:
            return "ja_JP"
        case .english:
            return "en_US"
        }
    }
}
