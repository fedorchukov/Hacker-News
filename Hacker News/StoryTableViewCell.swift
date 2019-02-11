//
//  StoryTableViewCell.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 08/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import UIKit
import CoreData

protocol StoryTableViewCellDelegate {
    func openUrl(_ url: URL)
}

class StoryTableViewCell: UITableViewCell {

    // MARK: - Delegates
    
    public var delegate: StoryTableViewCellDelegate?
    
    // MARK: - IBOutlets and Connections

    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var urlView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var autorLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var id: Int?
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    // MARK: - Life Cycle Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let tap = UITapGestureRecognizer(target: self, action: #selector(openUrl))
        urlView.addGestureRecognizer(tap)
    }
    
    // MARK: - User Defined Methods
    
    @objc private func openUrl() {
        if let urlString = urlLabel.text, let url = URL(string: urlString) {
            delegate?.openUrl(url)
        }
    }
    
    private func showPlaceholderView() {
        mainView.isHidden = true
        placeholderView.isHidden = false
        placeholderView.startShimmer()
    }
    
    private func hidePlaceholderView() {
        self.placeholderView.stopShimmer()
        self.placeholderView.isHidden = true
        self.mainView.isHidden = false
    }
    
    private func configureCell(from story: Story) {
        DispatchQueue.main.async {
            if self.id == Int(story.id) {
                self.titleLabel.text = story.title
                self.urlLabel.text = story.url
                self.autorLabel.text = story.by
                self.scoreLabel.text = String(story.score)
                self.commentsLabel.text = String(story.descendants)
                self.timeLabel.text = Date(timeIntervalSince1970: story.time).toShortString()
                self.hidePlaceholderView()
            }
        }
    }
	
    private func saveToDatabase(_ json: [String: Any]) {
        if let context = context {
            guard let story = Story.create(json: json, insertInto: context) else {
                return
            }
            configureCell(from: story)
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
	}
	
    private func loadFromDatabase(by id: Int, completionHandler: (_ success: Bool) -> Void) {
        if let context = context {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Story")
            fetchRequest.predicate = NSPredicate(format: "id = %d", id)
            
            do {
                let stories = try context.fetch(fetchRequest)
                assert(stories.count < 2, "Duplicate object in Core Data")
                if let story = stories.first as? Story {
                    configureCell(from: story)
                    completionHandler(true)
                    return
                }
                
            } catch let error as NSError {
                print("Could not read \(error), \(error.userInfo)")
            }
            completionHandler(false)
        }
    }

	private func loadFromServer(by id: Int) {
		NetworkManager.shared.getStory(by: id, completionHandler: { (data, response, error) -> Void in
			do {
				if let data = data, let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    self.saveToDatabase(json)
				}
			} catch let error as NSError {
				print(error)
			}
		})
	}
    
    func loadStory(by id: Int) {
        self.id = id
        showPlaceholderView()
        loadFromDatabase(by: id, completionHandler: { (succes) -> Void in
            if !succes {
                loadFromServer(by: id)
            }
        })
    }
}

