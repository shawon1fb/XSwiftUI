//
//  MediaContentModel.swift
//  XSwiftUI
//
//  Created by shahanul on 11/22/24.
//



import Foundation

//Media Content Model
public struct MediaContentModel: Codable, Hashable, Identifiable {
    
    public let id: UUID
    public let mediaType: MediaType
    public let imageURL: String?
    public let videoData: VideoData?
    public let gifURL: String?
    
    public init(id: UUID = UUID(), mediaType: MediaType, imageURL: String?, videoData: VideoData?, gifURL: String?) {
        self.id = id
        self.mediaType = mediaType
        self.imageURL = imageURL
        self.videoData = videoData
        self.gifURL = gifURL
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tempID = try? container.decodeIfPresent(UUID.self, forKey: .id)  // Make sure to add the id in your JSON if you're decoding it
        self.id = tempID ?? UUID()
        self.mediaType = try container.decode(MediaType.self, forKey: .mediaType)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        self.videoData = try container.decodeIfPresent(VideoData.self, forKey: .videoData)
        self.gifURL = try container.decodeIfPresent(String.self, forKey: .gifURL)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case mediaType
        case imageURL = "imageUrl"
        case videoData
        case gifURL = "gifUrl"
    }
}


public enum MediaType: String, Codable, Hashable {
  case gif = "gif"
  case image = "image"
  case video = "video"
}

//// MARK: - VideoData
public struct VideoData: Codable, Hashable {
  public let url: String
  public let thumbnail: String
  public let autoplay, autoRepeat: Bool

  public init(url: String, thumbnail: String, autoplay: Bool, autoRepeat: Bool) {
    self.url = url
    self.thumbnail = thumbnail
    self.autoplay = autoplay
    self.autoRepeat = autoRepeat
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.url = try container.decode(String.self, forKey: .url)
    self.thumbnail = try container.decode(String.self, forKey: .thumbnail)
    self.autoplay = try container.decode(Bool.self, forKey: .autoplay)
    self.autoRepeat = try container.decode(Bool.self, forKey: .autoRepeat)
  }
}


public extension MediaContentModel{
    
    static func image(url:String)->MediaContentModel{
        .init(mediaType: .image, imageURL: url, videoData: nil, gifURL: nil)
    }
    
}
