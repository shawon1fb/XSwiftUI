//
//  DImageWithSVG.swift
//  DecoraanUIComponents
//
//  Created by Shahanul Haque on 10/29/24.
//

import SwiftUI
import SVGView
import SDWebImageSwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct DImageWithSVG: View {
    let image: String
    
    var body: some View {
        VStack {
            if image.isSVGURL {
                CacheImageView(urlString: image) { state in
                    switch state {
                    case .idle:
                        Color.clear
                    case .loading:
                        ProgressView()
                    case .loaded(let resource):
                        if let svgString = String(data: resource.data, encoding: .utf8) {
                            SVGView(string: svgString)
                        } else {
                            #if os(iOS)
                            if let img = UIImage(data: resource.data) {
                                Image(uiImage: img)
                                    .resizable()
                            } else {
                                PlaceHolderImageView()
                            }
                            #elseif os(macOS)
                            if let img = NSImage(data: resource.data) {
                                Image(nsImage: img)
                                    .resizable()
                            } else {
                                PlaceHolderImageView()
                            }
                            #endif
                        }
                    case .error:
                        PlaceHolderImageView()
                    }
                }
            } else if let url = URL(string: image) {
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

#if DEBUG
struct DImageWithSVG_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DImageWithSVG(image: "https://example.com/test.svg")
            DImageWithSVG(image: "https://example.com/test.jpg")
            DImageWithSVG(image: "invalid-url")
        }
    }
}
#endif
