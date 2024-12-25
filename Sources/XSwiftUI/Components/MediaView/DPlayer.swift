import SwiftUI
import AVKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public struct DPlayer: View {
    @State var player: AVPlayer?
    @State var isMuted: Bool
    @State var autoRepeat: Bool = true
    @State private var autoplay: Bool
    private var onVideoEnd: (@Sendable () -> Void)?
    
    public init(
        url: String?,
        autoplay: Bool = false,
        isMuted: Bool = true,
        onVideoEnd: (@Sendable () -> Void)? = nil
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
                CrossPlatformVideoPlayer(
                    player: player,
                    isMuted: $isMuted,
                    autoRepeat: $autoRepeat,
                    onVideoEnd: onVideoEnd
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

#if os(iOS)
struct CrossPlatformVideoPlayer: UIViewControllerRepresentable {
    var player: AVPlayer
    @Binding var isMuted: Bool
    @Binding var autoRepeat: Bool
    var onVideoEnd: (@Sendable () -> Void)?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        configurePlayer(playerViewController)
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        updatePlayer(uiViewController)
    }
    
    private func configurePlayer(_ playerViewController: AVPlayerViewController) {
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        playerViewController.view.backgroundColor = .white
        player.isMuted = isMuted
        
        setupEndTimeObserver()
    }
    
    private func updatePlayer(_ playerViewController: AVPlayerViewController) {
        playerViewController.player = player
        player.isMuted = isMuted
        playerViewController.videoGravity = .resizeAspectFill
    }
}
#elseif os(macOS)
struct CrossPlatformVideoPlayer: NSViewRepresentable {
    var player: AVPlayer
    @Binding var isMuted: Bool
    @Binding var autoRepeat: Bool
    var onVideoEnd: (@Sendable () -> Void)?
    
    func makeNSView(context: Context) -> AVPlayerView {
        let playerView = AVPlayerView()
        configurePlayer(playerView)
        return playerView
    }
    
    func updateNSView(_ playerView: AVPlayerView, context: Context) {
        updatePlayer(playerView)
    }
    
    private func configurePlayer(_ playerView: AVPlayerView) {
        playerView.player = player
        playerView.controlsStyle = .none
        playerView.wantsLayer = true
        playerView.layer?.backgroundColor = NSColor.white.cgColor
        player.isMuted = isMuted
        
        setupEndTimeObserver()
    }
    
    private func updatePlayer(_ playerView: AVPlayerView) {
        playerView.player = player
        player.isMuted = isMuted
        playerView.videoGravity = .resizeAspectFill
    }
}
#endif

// Extension to share common functionality between platforms

extension CrossPlatformVideoPlayer {
    @MainActor
    func setupEndTimeObserver() {
        let autoRepeatValue = autoRepeat
        let onVideoEndCallback = onVideoEnd
        let playerRef = player
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            Task { @MainActor in
                if autoRepeatValue {
                    playerRef.seek(to: .zero)
                    playerRef.play()
                    print("played again")
                } else {
                    onVideoEndCallback?()
                }
            }
        }
    }
}

// Example Usage
struct ContentView: View {
    var body: some View {
        DPlayer(
            url: "https://github.com/shawon1fb/decoran_utils/raw/master/images/home/banner_section/92718-637669246_large.mp4",
            onVideoEnd: {
                print("Video ended")
            }
        )
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
