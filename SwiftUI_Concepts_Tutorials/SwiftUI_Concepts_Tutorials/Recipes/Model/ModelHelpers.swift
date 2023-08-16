import SwiftUI

func load<T: Decodable>(_ filename: String) -> T {
    let file = Bundle.main.url(forResource: filename, withExtension: nil)!
    let data = try! Data(contentsOf: file)
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try! decoder.decode(T.self, from: data)
}

final class ImageStore {
    typealias _ImageDictionary = [String: Image]
    fileprivate var images: _ImageDictionary = [:]
    fileprivate static var scale = 2
    static var shared = ImageStore()
    
    func image(name: String) -> Image {
        return images.values[_guaranteeImage(name: name)]
    }
    
    func add(_ image: Image, with name: String) {
        images[name] = image
    }
    
    static func loadImage(name: String) -> Image {
        let url = Bundle.main.url(forResource: name, withExtension: "jpg")!
        let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil)!
        let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)!
        
        return Image(cgImage, scale: CGFloat(ImageStore.scale), label: Text(""))
    }
    
    fileprivate func _guaranteeImage(name: String) -> _ImageDictionary.Index {
        if let index = images.index(forKey: name) { return index }
        
        images[name] = ImageStore.loadImage(name: name)
        return images.index(forKey: name)!
    }
}
