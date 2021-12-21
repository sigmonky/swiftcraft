//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by 206648481 on 8/16/21.
//

import XCTest
import EssentialFeed


// MARK:- Unit Tests

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let(_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
        
    }
    
    func test_load_requestsDataFromURL() {
        let inputURL = "https://somesite-specific.org"
        let url = URL(string: inputURL)!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
        let validateURL = client.requestedURLs[0]
        XCTAssertEqual(validateURL.absoluteString, inputURL)
        
    }
    
    func test_loadTwice_requestsDataFromURL() {
        
        let url = URL(string:"https://somesite-specific.org")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url,url])
        
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(.connectivity),
               when: {
                client.complete(with: NSError(domain: "Test", code: 0))
               }
        )
        
       
        
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let errorSamples = [201,202,203,204]
        errorSamples.enumerated().forEach { index, code in
            let json = makeItemsJson(items: [])
            expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
        
        
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
            let invalidJSON = Data("garbage".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([]),
               when: {
                    let emptyListJSON = makeItemsJson(items: [])
                    client.complete(withStatusCode: 200, data: emptyListJSON)
               }
        )
    }
    
    func test_load_deliversItemOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(),
                             imageURL: URL(string:"http://a-url.com")!)
        
        
        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string:"http://b-url.com")!)
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWithResult: .success(items), when: {
            let json = makeItemsJson(items: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
        
        
    }
    
    // MARK:-  Factories and Mocks
    
    private func makeSUT(url: URL = URL(string:"https://somesite-bogus.org")!,
                         file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy){
        
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
        
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject,
                                     file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Instance should have been de-allocated. Potential memory leak!", file: file, line: line)
        }
    }
    
    private func makeItem(id: UUID,
                          description: String? = nil,
                          location: String? = nil,
                          imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
       let item = FeedItem(id: id,
                           description: description,
                           location: location,
                           imageURL: imageURL)
        let json = ["id": id.uuidString,
                    "description": description,
                    "location": location,
                    "image": imageURL.absoluteString]
            .reduce(into: [String: Any]()) { (acc,e) in
                if let value = e.value {
                    acc[e.key] = value
                }     
            }
            
       return (item, json)
        
    }
    
    func makeItemsJson( items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    

    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithResult result: RemoteFeedLoader.Result,
                        when action: ()-> Void,
                        file: StaticString = #filePath, line: UInt = #line) {
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load {
            capturedResults.append($0)
        }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url,completion))
        }
        
        func complete(with error: Error, at index:Int = 0 ) {
            messages[index].completion(.failure(error))
        }
         
        func complete(withStatusCode code: Int, data: Data, at index:Int = 0) {
            
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
        
        
    }

}
