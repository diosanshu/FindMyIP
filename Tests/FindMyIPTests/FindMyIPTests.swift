import XCTest
import Combine
import Alamofire

@testable import FindMyIP

@available(iOS 13.0, *)
class FindMyIPViewModelTests: XCTestCase {
    var viewModel: FindMyIPViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = FindMyIPViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchDataSuccess() {
        let expectation = XCTestExpectation(description: "Data fetched successfully")

        // Mock Alamofire request using URLProtocol
        URLProtocolMock.testURLs = ["https://ipapi.co/json/": Data()] // Provide the desired response data

        // Start intercepting requests
        URLProtocol.registerClass(URLProtocolMock.self)

        viewModel.$content
            .dropFirst() // Skip initial nil value
            .sink { content in
                XCTAssertNotNil(content)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchData()

        wait(for: [expectation], timeout: 5.0)

        // Stop intercepting requests
        URLProtocol.unregisterClass(URLProtocolMock.self)
    }
    func testFetchDataFailure() {
        let expectation = XCTestExpectation(description: "Data fetching failed")

        // Mock Alamofire request using URLProtocol
        URLProtocolMock.testURLs = ["https://ipapi.co/json/": Data()] // Provide some data to trigger a failure
        URLProtocolMock.shouldFail = true // Simulate a failure

        // Start intercepting requests
        URLProtocol.registerClass(URLProtocolMock.self)

        viewModel.$errorMessage
            .dropFirst() // Skip initial nil value
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchData()

        wait(for: [expectation], timeout: 5.0)

        // Stop intercepting requests
        URLProtocol.unregisterClass(URLProtocolMock.self)
    }
}


// Mock URLProtocol to intercept network requests
class URLProtocolMock: URLProtocol {
    static var testURLs: [String: Data] = [:]
    static var shouldFail = false

    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url?.absoluteString else { return false }
        return testURLs.keys.contains(url)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url?.absoluteString, let data = URLProtocolMock.testURLs[url] else {
            return
        }
        
        if URLProtocolMock.shouldFail {
            let error = NSError(domain: "TestErrorDomain", code: 1234, userInfo: nil)
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        print("Loading finished for \(request.url?.absoluteString ?? "Unknown URL")")
      }
}


