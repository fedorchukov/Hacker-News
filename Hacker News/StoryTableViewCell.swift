//
//  StoryTableViewCell.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 08/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import UIKit

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
    
    private func configure(from story: Story) {
        if id == story.id {
            titleLabel.text = story.title
            urlLabel.text = story.url
            autorLabel.text = story.author
            scoreLabel.text = String(story.score)
            commentsLabel.text = String(story.comments)
            timeLabel.text = Date(timeIntervalSince1970: story.time).toShortString()
            hidePlaceholderView()
        }
    }
	
	
	private func saveToDatabase(_ story: Story, by id: Int) {
		DispatchQueue.main.async {
			UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: story), forKey: "\(id)")
			UserDefaults.standard.synchronize()
		}
	}
	
    private func loadFromDatabase(by id: Int) {
        DispatchQueue.main.async {
            if let storyObject = UserDefaults.standard.value(forKey: "\(id)") as? NSData, let story = NSKeyedUnarchiver.unarchiveObject(with: storyObject as Data) as? Story {
                self.configure(from: story)
            }
        }
    }

	private func loadFromServer(by id: Int) {
		NetworkManager.shared.getStory(by: id, completionHandler: { (data, response, error) -> Void in
			do {
				if let data = data, let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
					if let story = Story(json) {
						DispatchQueue.main.async {
							self.saveToDatabase(story, by: id)
							self.configure(from: story)
						}
					}
				}
			} catch let error as NSError {
				print(error)
			}
		})
	}
    
    func loadStory(by id: Int) {
        self.id = id
        showPlaceholderView()
        loadFromDatabase(by: id)
        loadFromServer(by: id)
    }
}

