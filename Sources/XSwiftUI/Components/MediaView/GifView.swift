import Foundation
import SwiftUI
import SDWebImageSwiftUI

// Define an environment key for aspect ratio
//struct AspectRatioKey: EnvironmentKey {
//  static let defaultValue: UIView.ContentMode = .scaleAspectFit
//}
//
//extension EnvironmentValues {
//  var aspectRatioMode: UIView.ContentMode {
//    get { self[AspectRatioKey.self] }
//    set { self[AspectRatioKey.self] = newValue }
//  }
//}
//
//public extension View {
//  func aspectRatioMode(_ mode: UIView.ContentMode) -> some View {
//    environment(\.aspectRatioMode, mode)
//  }
//}
//
//
//
//struct GifImage: UIViewRepresentable {
//  private let url: URL
//  @Environment(\.aspectRatioMode) private var aspectRatioMode
//  init(url: URL) {
//    self.url = url
//  }
//
//  func makeUIView(context: Context) -> UIView {
//    let container = UIView()
//    let imageView = UIImageView(gifURL: self.url)
//    imageView.translatesAutoresizingMaskIntoConstraints = false
//
//    //    imageView.contentMode = .scaleAspectFit
////    imageView.contentMode = .scaleToFill
//    //    imageView.contentMode = .scaleAspectFill
//      imageView.contentMode = self.aspectRatioMode
//    imageView.clipsToBounds = true
//    container.addSubview(imageView)
//
//    NSLayoutConstraint.activate([
//      imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//      imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//      imageView.topAnchor.constraint(equalTo: container.topAnchor),
//      imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
//    ])
//
//    return container
//
//  }
//
//  func updateUIView(_ uiView: UIView, context: Context) {
//    guard let imageView = uiView.subviews.first as? UIImageView else { return }
//    imageView.setGifFromURL(self.url)
//  }
//}

struct AnimatedImageView: View {
  let image: String
  var body: some View {
    VStack {
      if let url = URL(string: image) {
          AnimatedImage(url: url) {
          PlaceHolderImageView()
        }
          .resizable()
        .indicator(.activity)
        .transition(.fade(duration: 0.5))
      } else {
        PlaceHolderImageView()
      }

    }
  }
}

#Preview(body: {
  VStack {
    Spacer()
      AnimatedImageView(
      image: "https://raw.githubusercontent.com/shawon1fb/decoran_utils/master/images/home/brandings/Flow%203%40512p-25fps.gif"
    )
    
    .frame(width: 200, height: 150)
//    .scaledToFill()
//    .aspectRatioMode(.scaleAspectFill)
//    .aspectRatioMedia(.fill)
    .overlay(Color.gray.opacity(0.5))
    Spacer()
//      GifImage(url: URL(string: "https://raw.githubusercontent.com/shawon1fb/decoran_utils/master/images/home/brandings/Flow%203%40512p-25fps.gif")!)
//    .frame(width: 200, height: 150)
//    .aspectRatioMode(.scaleAspectFill)
//    .aspectRatioMedia(.fill)
//    .overlay(Color.gray.opacity(0.5))
//    Spacer()
  }
  .aspectRatio(contentMode: .fit)
})
