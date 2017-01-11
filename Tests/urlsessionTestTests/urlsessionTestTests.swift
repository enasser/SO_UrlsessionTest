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

    func testExample() {
        
        let sut = urlsessionTest()
        let exp = self.expectation(description: "testExample")

        sut.completionHandler = { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
            XCTAssertNil(error)
            let httpResponse = response as! HTTPURLResponse
            XCTAssertEqual(200, httpResponse.statusCode)
            exp.fulfill()
        }
        
        sut.testPost(username: "neo4j", password: "stack0verFlow", url: "http://192.168.0.18:7474/db/data/cypher")
        self.waitForExpectations(timeout: 3.0, handler: {error in
            XCTAssertNil(error, "\(error)")
        })
    }


    static var allTests : [(String, (urlsessionTestTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
