import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}

protocol EndPointURLSettable {
    static var url: String { get set }
    static var port: Int { get set }
}
