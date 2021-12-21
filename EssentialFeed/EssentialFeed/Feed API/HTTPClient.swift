//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by 206648481 on 12/17/21.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

// MARK: - protocols
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void )
    
}
