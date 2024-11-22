import AVKit
import SwiftUI

public struct DPlayer: View {

  @State var player: AVPlayer?
  @State var isMuted: Bool
  @State var autoRepeat: Bool = true
  @State private var autoplay: Bool
  private var onVideoEnd: (() -> Void)?

  public init(
    url: String?, autoplay: Bool = false, isMuted: Bool = true, onVideoEnd: (() -> Void)? = nil
  ) {
    self.autoplay = autoplay
    self._isMuted = State(initialValue: isMuted)
    self.onVideoEnd = onVideoEnd
    if let urlString = url, let videoURL = URL(string: urlString) {
      self._player = State(initialValue: AVPlayer(url: videoURL))
    }
  }

  public var body: some View {
    VStack(spacing: 0) {
      if let player = player {
        CustomVideoPlayer(
          player: player, isMuted: $isMuted, autoRepeat: $autoRepeat, onVideoEnd: onVideoEnd
        )

        .onAppear {
          if autoplay {
              
              
            player.play()
          } else {
            print("auto play off")
          }
        }
      } else {
        ProgressView()
      }
    }
  }
}

struct CustomVideoPlayer: UIViewControllerRepresentable {
  var player: AVPlayer
  @Binding var isMuted: Bool
  @Binding var autoRepeat: Bool
  var onVideoEnd: (() -> Void)?

  func makeUIViewController(context: Context) -> AVPlayerViewController {
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    playerViewController.showsPlaybackControls = false
    playerViewController.view.backgroundColor = .white
    player.isMuted = isMuted

    NotificationCenter.default.addObserver(
        forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main
    ) { _ in
      if autoRepeat {
        player.seek(to: .zero)
        player.play()
        print("payed again")
      } else {
        onVideoEnd?()
      }
    }

    return playerViewController
  }

  func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    uiViewController.player = player
    player.isMuted = isMuted
    // Ensure video fills the available space
    uiViewController.videoGravity = .resizeAspectFill
  }
}

// Example Usage
struct ContentView: View {
  var body: some View {
    DPlayer(
      url:
        "https://github.com/shawon1fb/decoran_utils/raw/master/images/home/banner_section/92718-637669246_large.mp4",
      onVideoEnd: {
        print("Video ended")
      }
    )

  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct MuteModifier: ViewModifier {

  @Binding var isMuted: Bool

  func body(content: Content) -> Content {
    content

  }
}
