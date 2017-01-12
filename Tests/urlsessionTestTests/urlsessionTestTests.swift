import Foundation
import XCTest
@testable import urlsessionTest

#if os(Linux)
    import Dispatch
#endif

class urlsessionTestTests: XCTestCase {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
    }

    func testThatPostIsReturning200() {

        let username = "neo4j"
        let password = "stack0verFlow"
        let urlString = "http://192.168.0.18:7474/db/data/cypher"
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

        let sut = urlsessionTest()
        let exp = self.expectation(description: "testThatPostIsReturning200")

        sut.completionHandler = { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            let httpResponse = response as! HTTPURLResponse
            XCTAssertEqual(200, httpResponse.statusCode)
            exp.fulfill()
        }

        do {
            try sut.testPost(username: username, password: password, url: urlString, postData: postData)
        } catch {
            XCTFail("Received errors while attempting to perform POST")
        }

        self.waitForExpectations(timeout: 3.0, handler: { error in
            XCTAssertNil(error, "\(error)")
        })
    }


    static var allTests : [(String, (urlsessionTestTests) -> () throws -> Void)] {
        return [
            ("testThatPostIsReturning200", testThatPostIsReturning200),
        ]
    }
}
