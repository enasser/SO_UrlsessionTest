import Foundation
import XCTest
#if os(Linux)
    import Dispatch
#endif

class urlsessionTest {

    let session: URLSession
    
    var completionHandler : ((Data?, URLResponse?, Error?) -> Void)?
    
    init() {
        let sessionConfiguration = URLSessionConfiguration.default
        
        sessionConfiguration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        sessionConfiguration.timeoutIntervalForRequest = 10
        sessionConfiguration.timeoutIntervalForResource = 20
        sessionConfiguration.httpAdditionalHeaders = ["Accept": "application/json", "Content-Type": "application/json; charset=UTF-8"]
        
        self.session = URLSession(configuration: sessionConfiguration,
                                  delegate: nil,
                                  delegateQueue: OperationQueue())
    }
    
    func testPost(username: String, password: String, url: String) {
        
        let postData: [String:Any] = [
            "query" : "CREATE (n:Person { props } ) RETURN n",
            "params" : [
                "props" : [
                    "position" : "Developer",
                    "name" : "Michael",
                    "awesome" : true,
                    "children" : 3
                ]
            ]
        ]
        
        let url = URL(string: url)!
        var httpRequest = URLRequest(url: url)
        httpRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        httpRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        let userAuthString: String = self.basicAuthString(username, password: password)
        httpRequest.setValue(userAuthString, forHTTPHeaderField: "Authorization")

        httpRequest.httpMethod = "POST"
        let transformedJSONData: Data = try! JSONSerialization.data(withJSONObject: postData, options: [])
        httpRequest.httpBody = transformedJSONData
        
        let task : URLSessionDataTask = session.dataTask(with: httpRequest, completionHandler:self.completionHandler!)
        
        task.resume()
        
    }
    
    func basicAuthString(_ username: String, password: String) -> String {
        
        let loginString = "\(username):\(password)"
        let loginData: Data = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString(options: [])
        let authString = "Basic \(base64LoginString)"
        
        return authString
    }
}

