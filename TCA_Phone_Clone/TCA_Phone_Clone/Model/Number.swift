import Foundation

enum Number: String {
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case hash = "#"
    case star = "*"
    
    var alphabet: String? {
        switch self {
        case .zero:
            return "+"
        case .one:
            return ""
        case .two:
            return "A B C"
        case .three:
            return "D E F"
        case .four:
            return "G H I"
        case .five:
            return "J K L"
        case .six:
           return "M N O"
        case .seven:
            return "P Q R S"
        case .eight:
            return "T U V"
        case .nine:
            return "W X Y Z"
        case .hash:
            return nil
        case .star:
            return nil
        }
    }
}
