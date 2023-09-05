import Foundation

enum WorldClockItem: Identifiable, Equatable, CaseIterable {
  case 서울
  case 갈라파고스제도
  case 과테말라시티
  case 그린베이
  case 녹스빌
  case 누크
  case 뉴욕
  case 두알라
  case 레드우드시티
  case 루안다
  case 마닐라
  
  var id: String {
    return String(describing: self)
  }
  
  var cityName: String {
    return String(describing: self)
  }
  
  var countryName: String {
    switch self {
    case .서울:
      return "대한민국"
    case .갈라파고스제도:
      return "에콰도르"
    case .과테말라시티:
      return "과테말라"
    case .그린베이:
      return "미국"
    case .녹스빌:
      return "미국"
    case .누크:
      return "그린란드"
    case .뉴욕:
      return "미국"
    case .두알라:
      return "카메룬"
    case .레드우드시티:
      return "미국"
    case .루안다:
      return "앙골라"
    case .마닐라:
      return "필리핀"
    }
  }
  
  var time: Date {
    let random = Double((-15...15).randomElement()!)
    return .now.addingTimeInterval(3600 * random)
  }
  
  var diff: String {
    let temp = Int((time.timeIntervalSinceNow / 3600))
    if temp >= 0 {
      return "+\(temp)"
    } else {
      return "\(temp)"
    }
  }
}
