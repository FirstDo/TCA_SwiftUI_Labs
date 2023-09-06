import Foundation
import AVFoundation

struct AudioService {
  private let audioPlayer: AVAudioPlayer
  
  init() {
    let sound = Bundle.main.path(forResource: "PocketCyclopsLvl1", ofType: "mp3")
    let url = URL(fileURLWithPath: sound!)
    self.audioPlayer = try! AVAudioPlayer(contentsOf: url)
  }
  
  func play() {
    if audioPlayer.isPlaying {
      audioPlayer.pause()
    }
    
    audioPlayer.play()
  }
  
  func stop() {
    audioPlayer.stop()
  }
}
