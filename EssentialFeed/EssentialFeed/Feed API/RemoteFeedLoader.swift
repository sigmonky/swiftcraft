//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by 206648481 on 8/20/21.
//

import Foundation

// MARK:- classes
public final class RemoteFeedLoader {
    
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
   
    public init(url: URL, client: HTTPClient) {
        
        self.client = client
        self.url = url
        
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        
        client.get(from: url) { result in
            
            switch result {
            case let .success(data, response):
                if let items = try? FeedItemsMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
            
        }
    }
    
}

