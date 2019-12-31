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

}
