//
//  File.swift
//
//
//  Created by Shahanul Haque on 7/13/24.
//
import Foundation
import SDWebImageSwiftUI
import SwiftUI
import WebKit


public struct MediaView: View {
  let model: MediaContentModel
    private var onVideoEnd: (@Sendable() -> Void)?
    public init(model: MediaContentModel, onVideoEnd: (@Sendable() -> Void)? = nil) {
      self.model = model
    self.onVideoEnd = onVideoEnd
  }

  public var body: some View {
    VStack {
      switch model.mediaType {
      case .gif:
        VStack(spacing: 0) {
          if let urlString = validateAndEncodeURL(from: model.gifURL) {
            AnimatedImageView(image: urlString)
          }
        }

      case .image:
              if let imageUrl = validateAndEncodeURL(from: model.imageURL) {
          DImageView2(image: imageUrl)
//                  DImageWithSVG(image: imageUrl)
        }

      case .video:
        if let videoModel = model.videoData {
          DPlayer(
            url: validateAndEncodeURL(from: videoModel.url), autoplay: videoModel.autoplay, onVideoEnd: onVideoEnd)
         
        }
      }
    }
  }
    
 
    
    func validateAndEncodeURL(from urlString: String?) -> String? {
        // Replace spaces with '%20' and validate the URL
        
        if let encodedURLString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return encodedURLString
        } else {
            return nil
        }
    }
}


//public struct MediaViewBindable: View {
//  @Binding var model: MediaContentModel?
//  private var onVideoEnd: (() -> Void)?
//  public init(model: Binding<MediaContentModel?>, onVideoEnd: (() -> Void)? = nil) {
//    self._model = model
//    self.onVideoEnd = onVideoEnd
//  }
//
//  public var body: some View {
//    VStack {
//        switch model?.mediaType {
//      case .gif:
//        VStack(spacing: 0) {
//            if let urlString = validateAndEncodeURL(from: model?.gifURL) {
//            AnimatedImageView(image: urlString)
//          }
//        }
//
//      case .image:
//                if let imageUrl = validateAndEncodeURL(from: model?.imageURL) {
//          DImageView2(image: imageUrl)
//        }
//
//      case .video:
//                if let videoModel = model?.videoData {
//          DPlayer(
//            url: validateAndEncodeURL(from: videoModel.url), autoplay: videoModel.autoplay, onVideoEnd: onVideoEnd)
//        }
//            case .none:
//                EmptyView()
//        }
//    }
//  }
//    
// 
//    
//    func validateAndEncodeURL(from urlString: String?) -> String? {
//        // Replace spaces with '%20' and validate the URL
//        
//        if let encodedURLString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//            return encodedURLString
//        } else {
//            return nil
//        }
//    }
//}


#Preview{

    if #available(macOS 12.0, *) {
        VStack {
            
            //MARK: video
            MediaView(
                model: MediaContentModel(
                    mediaType: MediaType.gif,
                    imageURL:
                        "https://raw.githubusercontent.com/shawon1fb/decoran_utils/e9a8d02c86430f18b274e8fec0b1cc73ccdc5406/icons/mdi_flash.svg",
                    videoData: VideoData(
                        url:
                            "https://github.com/shawon1fb/decoran_utils/raw/master/images/home/banner_section/92718-637669246_large.mp4",
                        thumbnail:
                            "https://s3-alpha-sig.figma.com/img/2dfd/2eb5/527b2de9974f1b769c4c22162d6cee07?Expires=1721606400&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=hu~aE2NzjU6daPkjY4Ha93i2gPyitwFM0Fdg8rrxvvmFq7Ht634QKeSoHfAALda5UJXfifjxpAPtEhL3xhfJSebgMYtR4pTWmPULS1I5dkGeQ8yYIUAKGU9AzOUunrx~rWPD5Ri4taI~cPtQZ5ij~SS5fenlnYQYb7G2NFL805MJf8nDDlduxsAwXfj-B9RRfT4S-c3K7K05Hcpet5wBi8t60JOa0eQKzePm02PtWn~vXRCEekY0BdHhfn2QnRs7OALz3MCYIPCcP41VJ-~7HLFkjVYbj8haSJxL8o2m7kxHqsA40m14oobGnAU2azQdNGEU5RotmzKQMNvn6ZiWAQ__",
                        autoplay: true, autoRepeat: false),
                    gifURL:
                        "https://raw.githubusercontent.com/shawon1fb/decoran_utils/master/images/home/brandings/Flow%203%40512p-25fps.gif"
                )
            )
            
            .frame(width: 200, height: 200)
            .aspectRatio(contentMode: .fit)
            .overlay(Color.red.opacity(0.2))
            
        }
        .background(.gray)
        .onAppear(perform: {
            
        })
    } else {
        // Fallback on earlier versions
    }
}

struct DImageView2: View {
  let image: String
  var body: some View {
    VStack {
      if let url = URL(string: image) {
          WebImage(url: url, options: [.retryFailed, .delayPlaceholder], context: [.imageThumbnailPixelSize : CGSize.zero]) { phase in
          switch phase {
          case .empty:
            EmptyView()
          case .success(let image):
            image.resizable()
          case .failure(_):
            PlaceHolderImageView()
          }
        }
        .indicator(.activity)
        .transition(.fade(duration: 0.5))
      } else {
        PlaceHolderImageView()
      }

    }
  }
}

struct DVideoView: View {
  let video: VideoData
  var body: some View {
    VStack(spacing: 0) {

      DPlayer(
        url:
          "https://github.com/shawon1fb/decoran_utils/raw/master/images/home/banner_section/92718-637669246_large.mp4"
      ) {

      }
    }
  }
}

struct PlaceHolderImageView: View {
  var body: some View {
    Rectangle()
          .foregroundStyle(Color(hex: "#F4F4F4"))
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay {
          Image(systemName: "apple.image.playground")
          .resizable()
          .scaledToFit()
          .frame(maxWidth: 74, maxHeight: 74)
      }

  }
}
