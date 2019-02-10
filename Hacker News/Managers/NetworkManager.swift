//
//  NetworkManager.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 10/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let baseUrl = URL(string: "https://hacker-news.firebaseio.com/v0/")!
    
    private init() {
        
    }
    
    func getStory(by id: Int, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("item/\(id).json")
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
            completionHandler(data, response, error)
        }).resume()
    }
    
    func getStories(by storiesType: StoriesType, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = baseUrl.appendingPathComponent("\(storiesType.rawValue).json")
        URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in
            completionHandler(data, response, error)
        }).resume()
    }
}

