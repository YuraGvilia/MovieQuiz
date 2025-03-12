import Foundation

struct MostPopularMovies: Codable {
    let items: [MostPopularMovie]
    let errorMessage: String?
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    // Пример вычисляемого URL для улучшенного качества изображения
    var resizedImageURL: URL {
        let urlString = imageURL.absoluteString
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        return URL(string: imageUrlString) ?? imageURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"    // "fullTitle" из JSON кладём в title
        case rating = "imDbRating"  // "imDbRating" в rating
        case imageURL = "image"     // "image" в imageURL
    }
}
