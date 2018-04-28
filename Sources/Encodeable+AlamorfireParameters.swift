import Alamofire

extension Encodable {

    public var parameters: Parameters? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
        } catch _ {
            return nil
        }
    }
}

