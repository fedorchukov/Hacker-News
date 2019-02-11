//
//  Stories.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 12/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import Foundation
import CoreData

extension ListOfStories {
    
    class func createOrUpdate(stories: [Int], type: String, insertInto context: NSManagedObjectContext?) -> ListOfStories? {
        guard let context = context, !stories.isEmpty else {
            return nil
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListOfStories")
        fetchRequest.predicate = NSPredicate(format: "type = %@", type)
        let result = try? context.fetch(fetchRequest)
        if let listOfStories = result?.first as? ListOfStories {
            listOfStories.stories = stories
            return listOfStories
        }
        
        let listOfStories = ListOfStories.init(entity: ListOfStories.entity(), insertInto: context)
        listOfStories.type = type
        listOfStories.stories = stories
        return listOfStories
    }
}

