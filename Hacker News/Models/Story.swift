//
//  Story.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 10/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import Foundation

class Story: NSObject, NSCoding {
    
    let id: Int
    let title: String
    let url: String?
    let author: String
    let score: Int
    let comments: Int
    let time: TimeInterval
    
    init(id: Int, title: String, url: String?, author: String, score: Int, comments: Int, time: TimeInterval) {
        self.id = id
        self.title = title
        self.url = url
        self.author = author
        self.score = score
        self.comments = comments
        self.time = time
    }
    
    convenience init?(_ response: [String: Any]) {
        guard
            let id = response["id"] as? Int,
            let title = response["title"] as? String,
            let author = response["by"] as? String,
            let score = response["score"] as? Int,
            let comments = response["descendants"] as? Int,
            let time = response["time"] as? TimeInterval
        else {
            return nil
        }
        
        let url = response["url"] as? String
        
        self.init(id: id, title: title, url: url, author: author, score: score, comments: comments, time: time)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        self.url = aDecoder.decodeObject(forKey: "url") as? String ?? ""
        self.author = aDecoder.decodeObject(forKey: "by") as? String ?? ""
        self.score = aDecoder.decodeInteger(forKey: "score")
        self.comments = aDecoder.decodeInteger(forKey: "descendants")
        self.time = aDecoder.decodeDouble(forKey: "time")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(author, forKey: "by")
        aCoder.encode(score, forKey: "score")
        aCoder.encode(comments, forKey: "descendants")
        aCoder.encode(time, forKey: "time")
    }
}

