import Foundation
#if os(Linux)
    import Dispatch
#endif

public final class urlsessionTest {

    private let session: URLSession
    private let sessionConfiguration: URLSessionConfiguration

    public var completionHandler : ((Data?, URLResponse?, Error?) -> Void)?

    public init() {

        sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        sessionConfiguration.timeoutIntervalForRequest = 10
        sessionConfiguration.timeoutIntervalForResource = 20

        session = URLSession(configuration: sessionConfiguration,
                             delegate: nil,
                             delegateQueue: OperationQueue())
    }

    public enum LocalError: Error {
        case cannotConvertUTF8ToData
        case cannotConvertStringToURL
        case completionHandlerMustBeSetBeforeCallingPost
    }


    public func testPost(username: String, password: String, url: String, postData: [String:Any]) throws {

        guard let url = URL(string: url) else {
            throw LocalError.cannotConvertStringToURL
        }

        guard let completionHandler = completionHandler else {
            throw LocalError.completionHandlerMustBeSetBeforeCallingPost
        }

        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        httpRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let userAuthString: String = try basicAuthString(username, password: password)
        httpRequest.setValue(userAuthString, forHTTPHeaderField: "Authorization")

        let transformedJSONData: Data = try JSONSerialization.data(withJSONObject: postData, options: [])
        httpRequest.httpBody = transformedJSONData

        let task : URLSessionDataTask = session.dataTask(with: httpRequest, completionHandler:completionHandler)

        task.resume()

    }

    private func basicAuthString(_ username: String, password: String) throws -> String {

        let loginString = "\(username):\(password)"
        guard let loginData: Data = loginString.data(using: .utf8) else {
            throw LocalError.cannotConvertUTF8ToData
        }
        let base64LoginString = loginData.base64EncodedString(options: [])
        let authString = "Basic \(base64LoginString)"

        return authString
    }
}
