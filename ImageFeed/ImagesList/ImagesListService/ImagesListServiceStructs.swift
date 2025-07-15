import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let description: String?
    let likedByUser: Bool
    let width: Int
    let height: Int
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id, description, urls, width, height
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}
