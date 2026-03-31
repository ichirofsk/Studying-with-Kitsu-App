//
// Playground Template developed by Apple Developer Academy | PUC-Rio
// Version 1.0
//
// This template playground is built based on the 10th Submission Requirement of
// the Swift Student Challenge WWDC26: "Your app playground must either [...] or
// be based on a Swift Playground template modified entirely by you as an individual."
//

import AVFoundation

@MainActor
@Observable
class BasicAudioController {
    
    let audioPlayer: AVAudioPlayer
    var isPlaying: Bool { audioPlayer.isPlaying }
    
    init?(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("BasicAudioController could not find file with name \(filename.debugDescription)")
            return nil
        }
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("Error: \(filename.debugDescription) audio file not found in your project.")
            return nil
        }
    }
    
    func play() {
        audioPlayer.play()
    }
    
    func pause() {
        audioPlayer.pause()
    }
    
    func stop() {
        audioPlayer.pause()
        audioPlayer.currentTime = 0
    }
}
