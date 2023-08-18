import Foundation
import SwiftUI

enum Style {
    case normal
    case detail(description: String)
    case toggle
}

extension Cell {
    static let first: [Cell] = [
        .airpod
    ]
    static let second: [Cell] = [
        .airplaneMode ,.wifi, .bluetooth, .cellular, .hotsopt, .vpn
    ]
    static let third: [Cell] = [
        .alarm, .soundAndHaptic, .concentrationMode, .screenTime
    ]
}

enum Cell: String, CaseIterable, Identifiable {
    case airpod = "도연의 AirPods Pro 2"
    case airplaneMode = "에어플레인 모드"
    case wifi = "Wi-Fi"
    case bluetooth = "Bluetooth"
    case cellular = "셀룰러"
    case hotsopt = "개인용 핫스팟"
    case vpn = "VPN"
    case alarm = "알림"
    case soundAndHaptic = "사운드 및 햅틱"
    case concentrationMode = "집중 모드"
    case screenTime = "스크린 타임"
    
    var id: String {
        return self.rawValue
    }
    
    var style: Style {
        switch self {
        case .airpod: return .normal
        case .airplaneMode: return .toggle
        case .wifi: return .detail(description: "dudu의 wifi")
        case .bluetooth: return .detail(description: "켬")
        case .cellular: return .normal
        case .hotsopt: return .detail(description: "끔")
        case .vpn: return .detail(description: "연결 안 됨")
        case .alarm: return .normal
        case .soundAndHaptic: return .normal
        case .concentrationMode: return .normal
        case .screenTime: return .normal
        }
    }
    
    var imageName: String {
        switch self {
        case .airpod: return "airpodspro"
        case .airplaneMode: return "airplane"
        case .wifi: return "wifi"
        case .bluetooth: return "swift"
        case .cellular: return "antenna.radiowaves.left.and.right"
        case .hotsopt: return "personalhotspot"
        case .vpn: return "swift"
        case .alarm: return "bell.badge.fill"
        case .soundAndHaptic: return "speaker.wave.2.fill"
        case .concentrationMode: return "moon.fill"
        case .screenTime: return "hourglass"
        }
    }
    
    var tintColor: Color {
        switch self {
        case .airpod: return .gray
        case .airplaneMode: return .orange
        case .wifi: return .blue
        case .bluetooth: return .blue
        case .cellular: return .green
        case .hotsopt: return .green
        case .vpn: return .blue
        case .alarm: return .red
        case .soundAndHaptic: return .red
        case .concentrationMode: return .purple
        case .screenTime: return .purple
        }
    }
}
