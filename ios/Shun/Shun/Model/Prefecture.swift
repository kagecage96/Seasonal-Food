enum Prefecture: CaseIterable {
    case hokkaido
    case aomori
    case iwate
    case miyagi
    case akita
    case yamagata
    case fukushima
    case ibaraki
    case tochigi
    case gunma
    case saitama
    case chiba
    case tokyo
    case kanagawa
    case niigata
    case toyama
    case ishikawa
    case fukui
    case yamanashi
    case nagano
    case gifu
    case shizuoka
    case aichi
    case mie
    case shiga
    case kyoto
    case osaka
    case hyogo
    case nara
    case wakayama
    case tottori
    case shimane
    case okayama
    case hiroshima
    case yamaguchi
    case tokushima
    case kagawa
    case ehime
    case kochi
    case fukuoka
    case saga
    case nagasaki
    case kumamoto
    case oita
    case miyazaki
    case kagoshima
    case okinawa
    
    var name: String {
        switch self {
        case .hokkaido: return "北海道"
        case .aomori   : return "青森"
        case .iwate    : return "岩手"
        case .miyagi   : return "宮城"
        case .akita    : return "秋田"
        case .yamagata : return "山形"
        case .fukushima: return "福島"
        case .ibaraki : return "茨城"
        case .tochigi : return "栃木"
        case .gunma   : return "群馬"
        case .saitama : return "埼玉"
        case .chiba   : return "千葉"
        case .tokyo   : return "東京"
        case .kanagawa: return "神奈川"
        case .niigata  : return "新潟"
        case .toyama   : return "富山"
        case .ishikawa : return "石川"
        case .fukui    : return "福井"
        case .yamanashi: return "山梨"
        case .nagano   : return "長野"
        case .gifu     : return "岐阜"
        case .shizuoka : return "静岡"
        case .aichi    : return "愛知"
        case .mie     : return "三重"
        case .shiga   : return "滋賀"
        case .kyoto   : return "京都"
        case .osaka   : return "大阪"
        case .hyogo   : return "兵庫"
        case .nara    : return "奈良"
        case .wakayama: return "和歌山"
        case .tottori  : return "鳥取"
        case .shimane  : return "島根"
        case .okayama  : return "岡山"
        case .hiroshima: return "広島"
        case .yamaguchi: return "山口"
        case .tokushima: return "徳島"
        case .kagawa   : return "香川"
        case .ehime    : return "愛媛"
        case .kochi    : return "高知"
        case .fukuoka  : return "福岡"
        case .saga     : return "佐賀"
        case .nagasaki : return "長崎"
        case .kumamoto : return "熊本"
        case .oita     : return "大分"
        case .miyazaki : return "宮崎"
        case .kagoshima: return "鹿児島"
        case .okinawa  : return "沖縄"
        }
    }
    
    var engName: String {
          switch self {
          case .hokkaido: return "hokkaido"
          case .aomori   : return "aomori"
          case .iwate    : return "iwate"
          case .miyagi   : return "miyagi"
          case .akita    : return "akita"
          case .yamagata : return "yamagata"
          case .fukushima: return "fukushima"
          case .ibaraki : return "ibaraki"
          case .tochigi : return "tochigi"
          case .gunma   : return "gunma"
          case .saitama : return "saitama"
          case .chiba   : return "chiba"
          case .tokyo   : return "tokyo"
          case .kanagawa: return "kanagawa"
          case .niigata  : return "niigata"
          case .toyama   : return "toyama"
          case .ishikawa : return "ishikawa"
          case .fukui    : return "fukui"
          case .yamanashi: return "yamanashi"
          case .nagano   : return "nagano"
          case .gifu     : return "gifu"
          case .shizuoka : return "shizuoka"
          case .aichi    : return "shizuoka"
          case .mie     : return "mie"
          case .shiga   : return "shiga"
          case .kyoto   : return "kyoto"
          case .osaka   : return "osaka"
          case .hyogo   : return "hyogo"
          case .nara    : return "nara"
          case .wakayama: return "wakayama"
          case .tottori  : return "tottori"
          case .shimane  : return "shimane"
          case .okayama  : return "okayama"
          case .hiroshima: return "hiroshima"
          case .yamaguchi: return "yamaguchi"
          case .tokushima: return "tokushima"
          case .kagawa   : return "kagawa"
          case .ehime    : return "ehime"
          case .kochi    : return "kochi"
          case .fukuoka  : return "fukuoka"
          case .saga     : return "saga"
          case .nagasaki : return "nagasaki"
          case .kumamoto : return "kumamoto"
          case .oita     : return "oita"
          case .miyazaki : return "miyazaki"
          case .kagoshima: return "kagoshima"
          case .okinawa  : return "okinawa"
          }
      }
    
    func name(language: Language) -> String {
        if language == .japanese {
            return name
        } else {
            return engName
        }
    }
}
