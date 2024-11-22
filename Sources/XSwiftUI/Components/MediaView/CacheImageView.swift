////
////  CacheImageView.swift
////
////
////  Created by shahanul on 30/6/24.
////
//
//import Foundation
//import SVGKit
//import SwiftUI
//
//class CacheDIContainer {
//  // Create a private static instance of the class
//  private static let sharedContainer = CacheDIContainer()
//
//  // Make the initialiser private to prevent creating instances from outside the class
//  private init() {
//    instancesMap = [:]
//    instancesCount = [:]
//  }
//
//  // Create a static property to access the shared instance
//  static var shared: CacheDIContainer {
//    return sharedContainer
//  }
//
//  private var instancesMap: [String: ImageViewModel]
//  private var instancesCount: [String: Int]
//
//  func getVM(url: String) -> ImageViewModel {
//    //        print("\(url) => \(instancesCount[url]?.description ?? "-0" ) \(instancesMap[url] == nil)")
//    if let vm = instancesMap[url] {
//      if let count = instancesCount[url] {
//        instancesCount[url] = count + 1
//      } else {
//        instancesCount[url] = 1
//      }
//      return vm
//    } else {
//      let vm = ImageViewModel(urlString: url)
//      instancesMap[url] = vm
//      instancesCount[url] = 1
//      return vm
//    }
//  }
//
//  func removeVM(url: String) {
//    if let _ = instancesMap[url] {
//      if let count = instancesCount[url] {
//        instancesCount[url] = count - 1
//        if count < 1 {
//          instancesCount[url] = 0
//          instancesMap.removeValue(forKey: url)
//          //                    print("remove url -> \(url)")
//          //
//          //                    print("active -> ",instancesMap.count )
//        }
//      } else {
//        instancesCount[url] = 0
//        instancesMap.removeValue(forKey: url)
//        //                print("remove url -> \(url) ")
//        //                print("active -> ",instancesMap.count )
//      }
//    } else {
//      instancesCount[url] = 0
//      instancesMap[url] = nil
//    }
//  }
//
//  // Add your other properties and methods here...
//}
//
//actor ImageFetcher: NSObject {
//  private var imageCache: NSCache<NSString, UIImage> = NSCache()
//
//  static let shared = ImageFetcher()
//
//  // Private initializer to prevent external instantiation
//  private override init() {}
//
//  func fetchImage(from urlString: String) async -> UIImage? {
//    // Check the cache first
//    if let cachedImage = imageCache.object(forKey: urlString as NSString) {
//      return cachedImage
//    }
//
//    guard let url = URL(string: urlString) else {
//      return nil
//    }
//
//    do {
//      let (data, _) = try await URLSession.shared.data(from: url)
//      let image = await self.processImageData(data, for: urlString)
//      return image
//    } catch {
//      print("Failed to fetch image: \(error)")
//      return nil
//    }
//  }
//
//  private func processImageData(_ data: Data, for urlString: String) async -> UIImage? {
//    if let image = UIImage(data: data) {
//      // Cache the UIImage if it's a valid bitmap image
//      imageCache.setObject(image, forKey: urlString as NSString)
//      return image
//    } else {
//      // Try converting SVG data to UIImage
//      let svgImage = svgDataToUIImage(data: data)
//      // Cache the SVG UIImage if it's valid
//      if let svgUIImage = svgImage {
//        imageCache.setObject(svgUIImage, forKey: urlString as NSString)
//      }
//      return svgImage
//    }
//  }
//}
//
//class ImageViewModel: ObservableObject {
//  @Published var image: UIImage?
//  @Published var hasError: Bool = false
//
//  private let fetcher = ImageFetcher.shared
//  private var urlString: String
//
//  init(urlString: String) {
//    self.urlString = urlString
//  }
//
//  @MainActor
//  func loadImage() async {
//      
//      if let _ = image{
//          return
//      }
//
//    if let loadedImage = await fetcher.fetchImage(from: urlString) {
//      image = loadedImage
//      hasError = false
//    } else {
//      hasError = true
//    }
//
//  }
//}
//
//public struct CacheImageView<Content: View>: View {
//  @ObservedObject private var imageViewModel: ImageViewModel
//
//  @ViewBuilder var content: (UIImage?, Bool) -> Content
//
//  private var url: String
//
//  public init(
//    urlString: String,
//    content: @escaping (UIImage?, Bool) -> Content
//  ) {
//    url = urlString
//    imageViewModel = CacheDIContainer.shared.getVM(url: urlString)
//    self.content = content
//  }
//
//  public var body: some View {
//    VStack {
//      if let image = imageViewModel.image {
//        // return image
//        content(image, false)
//
//      } else {
//        // MARK: loading
//
//        content(nil, imageViewModel.hasError)
//      }
//    }
//    .task {
//        if let _ = imageViewModel.image{}else{
//            await imageViewModel.loadImage()
//        }
//     
//    }
//    .onDisappear {
//      //onDisappear()
//    }
//  }
//
//  func onDisappear() {
//    CacheDIContainer.shared.removeVM(url: url)
//  }
//}
//
//struct CacheImageView_Previews: PreviewProvider {
//  static var previews: some View {
//    VStack {
//      CacheImageView(
//        urlString:
//          "https://raw.githubusercontent.com/shawon1fb/decoran_utils/e9a8d02c86430f18b274e8fec0b1cc73ccdc5406/icons/mdi_flash.svg"
//      ) { image, error in
//
//        VStack {
//          if let img = image {
//            Image(uiImage: img)
//              .resizable()
//            //              .frame(width: 60, height: 60)
//
//          } else if error == true {
//            Text("Url error")
//          } else {
//            Text("Loading ")
//          }
//        }
//      }
//      //
//      //      CacheImageView(
//      //        urlString: "https://media-1.api-sports.io/football/teams/16808.png"
//      //      ) { image, error in
//      //
//      //        VStack {
//      //          if let img = image {
//      //            Image(uiImage: img)
//      //              .resizable()
//      //              .frame(width: 60, height: 60)
//      //
//      //          } else if error == true {
//      //            Text("Url error")
//      //          } else {
//      //            Text("Loading ")
//      //          }
//      //        }
//      //      }
//      //
//      //      CacheImageView(
//      //        urlString: "https://developer.apple.com/news/images/og/swiftui-og.png"
//      //      ) { image, error in
//      //
//      //        VStack {
//      //          if let img = image {
//      //            Image(uiImage: img)
//      //              .resizable()
//      //              .frame(width: 60, height: 60)
//      //
//      //          } else if error == true {
//      //            Text("Url error")
//      //          } else {
//      //            Text("Loading ")
//      //          }
//      //        }
//      //      }
//      //
//      //      CacheImageView(
//      //        urlString: "https://media-3.api-sports.io/football/leagues/10.png"
//      //      ) { image, error in
//      //
//      //        VStack {
//      //          if let img = image {
//      //            Image(uiImage: img)
//      //              .resizable()
//      //              .frame(width: 60, height: 60)
//      //
//      //          } else if error == true {
//      //            Text("Url error")
//      //          } else {
//      //            Text("Loading ")
//      //          }
//      //        }
//      //      }
//
//      //        RemoteSVGImageView(urlString: "https://raw.githubusercontent.com/shawon1fb/decoran_utils/e9a8d02c86430f18b274e8fec0b1cc73ccdc5406/icons/mdi_flash.svg")
//      //            .frame(width: 24,height: 24)
//    }
//  }
//}
//
//func svgDataToUIImage(data: Data) -> UIImage? {
//  let svgImage = SVGKImage(data: data)
//  return svgImage?.uiImage
//}
//
//extension UIView {
//    func asImage() -> UIImage {
//        let renderer = UIGraphicsImageRenderer(bounds: bounds)
//        return renderer.image { rendererContext in
//            layer.render(in: rendererContext.cgContext)
//        }
//    }
//}
