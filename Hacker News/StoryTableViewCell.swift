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
    
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var cellView: UIView!
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
    
    func loadData(by id: Int) {
        self.id = id
        
        myView.isHidden = false
        cellView.isHidden = true
        myView.startShimmer()

        NetworkManager.shared.getStory(by: id, completionHandler: { (data, response, error) -> Void in
            
            do {
                if let data = data, let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    if let story = Story(json) {
                        // save story to database
                        
                        DispatchQueue.main.async {
                            if self.id == story.id {
                                self.titleLabel.text = story.title
                                self.urlLabel.text = story.url
                                self.autorLabel.text = story.author
                                self.scoreLabel.text = String(story.score)
                                self.commentsLabel.text = String(story.comments)
                                self.timeLabel.text = Date(timeIntervalSince1970: story.time).toShortString()
                                
                                self.myView.stopShimmer()
                                self.myView.isHidden = true
                                self.cellView.isHidden = false
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        })
    }
}

