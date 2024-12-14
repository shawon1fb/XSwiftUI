import SwiftUI
import SVGView

// MARK: - Models
public struct CachedImageResource: Equatable, Sendable {
    let urlString: String
    let data: Data
    
    var asCacheKey: String {
        urlString
    }
}

// MARK: - Cache
actor ImageCache {
    static let shared = ImageCache()
    private var cache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>()
        cache.countLimit = 100
        return cache
    }()
    
    private init() {}
    
    func store(_ resource: CachedImageResource) {
        cache.setObject(resource.data as NSData, forKey: resource.asCacheKey as NSString)
    }
    
    func retrieve(for urlString: String) -> CachedImageResource? {
        guard let data = cache.object(forKey: urlString as NSString) as? Data else {
            return nil
        }
        return CachedImageResource(urlString: urlString, data: data)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}

// MARK: - Image Fetcher
actor ImageFetcher {
    static let shared = ImageFetcher()
    private let cache = ImageCache.shared
    
    private init() {}
    
    func fetchImage(from urlString: String) async -> Result<CachedImageResource, ImageError> {
        // Check cache first
        if let cachedResource = await cache.retrieve(for: urlString) {
            return .success(cachedResource)
        }
        
        // Fetch if not cached
        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let resource = CachedImageResource(urlString: urlString, data: data)
            await cache.store(resource)
            return .success(resource)
        } catch {
            return .failure(.networkError(error))
        }
    }
}

// MARK: - View Model
@MainActor
class ImageViewModel: ObservableObject {
    @Published private(set) var state: ImageLoadingState = .idle
    private let urlString: String
    private let fetcher: ImageFetcher
    
    init(urlString: String, fetcher: ImageFetcher = .shared) {
        self.urlString = urlString
        self.fetcher = fetcher
    }
    
    func loadImage() async {
        guard case .idle = state else { return }
        
        state = .loading
        let result = await fetcher.fetchImage(from: urlString)
        
        switch result {
        case .success(let resource):
            state = .loaded(resource)
        case .failure(let error):
            state = .error(error)
        }
    }
}

// MARK: - View Model Factory
@MainActor
class ImageViewModelFactory {
    static let shared = ImageViewModelFactory()
    
    private var viewModels: [String: WeakRef<ImageViewModel>] = [:]
    
    private init() {}
    
    func viewModel(for urlString: String) -> ImageViewModel {
        if let existingVM = viewModels[urlString]?.value {
            return existingVM
        }
        
        let newVM = ImageViewModel(urlString: urlString)
        viewModels[urlString] = WeakRef(newVM)
        return newVM
    }
    
    func cleanup() {
        viewModels = viewModels.filter { $0.value.value != nil }
    }
}

// MARK: - Supporting Types
public enum ImageLoadingState: Equatable {
    case idle
    case loading
    case loaded(CachedImageResource)
    case error(ImageError)
    
    static public func == (lhs: ImageLoadingState, rhs: ImageLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let lhsImage), .loaded(let rhsImage)):
            return lhsImage == rhsImage
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

public enum ImageError: Error, Equatable {
    case invalidURL
    case networkError(Error)
    
    static public func == (lhs: ImageError, rhs: ImageError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.networkError, .networkError):
            return true
        default:
            return false
        }
    }
}

class WeakRef<T: AnyObject> {
    private(set) weak var value: T?
    
    init(_ value: T) {
        self.value = value
    }
}


public struct CacheImageView<Content: View>: View {
    @StateObject private var viewModel: ImageViewModel
    private let content: (ImageLoadingState) -> Content
    
    public init(
        urlString: String,
        @ViewBuilder content: @escaping (ImageLoadingState) -> Content
    ) {
        self._viewModel = StateObject(
            wrappedValue: ImageViewModelFactory.shared.viewModel(for: urlString)
        )
        self.content = content
    }
    
    public var body: some View {
        content(viewModel.state)
            .task {
                await viewModel.loadImage()
            }
    }
}

// MARK: - Usage Example
struct ExampleUsage: View {
    var body: some View {
        CacheImageView(urlString: "http://192.168.11.200:9000/decoraan/category/6199010322598087782-furniture.svg") { state in
            switch state {
            case .idle:
                Color.clear
            case .loading:
                ProgressView()
            case .loaded(let resource):
                if let svgString = String(data: resource.data, encoding: .utf8) {
                    SVGView(string: svgString)
                } else {
                    Image(systemName: "exclamationmark.triangle")
                }
            case .error:
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
            }
        }
        .frame(width: 50, height: 50)
    }
}


#Preview(body: {
    ExampleUsage()
})

extension String {
    var isSVGURL: Bool {
        // Check if empty
        guard !self.isEmpty else { return false }
        
        // First check the file extension
        let fileExtensionCheck = self.lowercased().hasSuffix(".svg")
        
        // Check for data URLs
        if self.lowercased().starts(with: "data:") {
            return self.lowercased().contains("image/svg+xml")
        }
        
        // If it's a file extension match, return true
        if fileExtensionCheck {
            return true
        }
        
        // For URLs without clear extensions, try to parse the URL
        guard let url = URL(string: self) else { return false }
        
        // Check path extension
        if !url.pathExtension.isEmpty {
            return url.pathExtension.lowercased() == "svg"
        }
        
        // Check for SVG in the path components
        let pathComponents = url.pathComponents
        return pathComponents.contains { component in
            let comp = component.lowercased()
            return comp.hasSuffix(".svg") ||
                   comp.contains("svg") && comp.contains("image")
        }
    }
    
    // Async version that actually checks the content type
    func isSVGURLWithContentTypeCheck() async -> Bool {
        // If it's already clearly an SVG based on the URL, return true
        if self.isSVGURL {
            return true
        }
        
        // Otherwise, try to fetch headers to check content type
        guard let url = URL(string: self) else { return false }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"  // Only fetch headers, not content
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") {
                return contentType.lowercased().contains("image/svg+xml")
            }
            
            return false
        } catch {
            return false
        }
    }
}
