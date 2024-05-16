import Foundation

class Movie {
    var id: String
    var title: String
    var description: String
    var images: [String]
    
    init(id: String, title: String, description: String, images: [String]) {
        self.id = id
        self.title = title
        self.description = description
        self.images = images
    }
}
