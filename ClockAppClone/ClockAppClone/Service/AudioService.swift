import Foundation
import AVFoundation

struct AudioService {
  
  private var audioPlayer: AVAudioPlayer!
  
  enum Sound: String {
    case ex = "ex"
  }
  
  mutating func playSound(_ name: Sound) {
    guard let url = Bundle.main.url(forResource: name.rawValue, withExtension: "mp3") else { return }
    
    audioPlayer = try! AVAudioPlayer(contentsOf: url)
    audioPlayer.prepareToPlay()
    audioPlayer.play()
  }
}
