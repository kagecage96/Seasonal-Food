enum Language {
     case japanese
    
     var name: String {
        switch self {
        case .japanese: return "japanese"
        }
    }
}
