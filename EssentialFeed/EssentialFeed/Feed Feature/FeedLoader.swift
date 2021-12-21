//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by 206648481 on 8/12/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
