//
//  Story.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 10/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import Foundation
import CoreData

extension Story {
    
    class func create(json: [String: Any], insertInto context: NSManagedObjectContext?) -> Story? {
        guard let context = context, let id = json["id"] as? Int64 else {
            return nil
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Story")
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
        let stories = try? context.fetch(fetchRequest)
        if let story = stories?.first as? Story {
            return story
        }
        
        let story = Story.init(entity: Story.entity(), insertInto: context)
        story.id = id
        story.title = json["title"] as? String
        story.by = json["by"] as? String
        story.score = json["score"] as? Int64 ?? 0
        story.descendants = json["descendants"] as? Int64 ?? 0
        story.time = json["time"] as? Double ?? 0
        story.url = json["url"] as? String
        return story
    }
}

