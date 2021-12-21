//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by 206648481 on 12/17/21.
//

import Foundation

internal class FeedItemsMapper {
    
    private static var OK_200: Int {
        return 200
    }
    
    private struct Item : Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var normalizedItem: FeedItem {
            return FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: image)
        }
    }


    private struct Root: Decodable {
        let items: [Item]
    }
    
    internal static func map(_ data: Data,_ response: HTTPURLResponse) throws ->  [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return try JSONDecoder().decode(Root.self, from: data)
            .items
            .map{ $0.normalizedItem}
    }
    
}
