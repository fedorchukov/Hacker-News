//
//  TableViewController.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 07/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class TableViewController: UITableViewController {

    // MARK: - IBOutlets and Connections
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Local Constants and Variables
    
    private var stories = [Int]()
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: String(describing: StoryTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: StoryTableViewCell.self))
        getStories()
        refreshControl?.addTarget(self, action: #selector(getStories), for: .valueChanged)
    }

    // MARK: - UITableViewDelegate Methods

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 168
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    // MARK: - UITableViewDataSource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StoryTableViewCell.self), for: indexPath) as! StoryTableViewCell
        cell.delegate = self
        cell.loadStory(by: stories[indexPath.row])
        return cell
    }
    
    // MARK: - User Defined Methods
	
    private func saveToDatabase(_ stories: [Int], by storiesType: StoriesType) {
        if let context = context {
            guard ListOfStories.createOrUpdate(stories: stories, type: storiesType.rawValue, insertInto: context) != nil else {
                return
            }

            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
	}
	
	private func loadFromDatabase(by storiesType: StoriesType) {
        if let context = context {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListOfStories")
            fetchRequest.predicate = NSPredicate(format: "type = %@", storiesType.rawValue)
            
            do {
                let result = try context.fetch(fetchRequest)
                assert(result.count < 2, "Duplicate object in Core Data")
                if let listOfStories = result.first as? ListOfStories, let stories = listOfStories.stories, !stories.isEmpty, self.stories != stories {
                    DispatchQueue.main.async {
                        self.stories = stories
                        self.tableView.reloadData()
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    }
                }
                
            } catch let error as NSError {
                print("Could not read \(error), \(error.userInfo)")
            }
        }
	}
	
	private func loadFromServer(by storiesType: StoriesType) {
		NetworkManager.shared.getStories(by: storiesType, completionHandler: { (data, response, error) -> Void in
			do {
				if let data = data, let stories = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Int] {
					DispatchQueue.main.async {
						self.refreshControl?.endRefreshing()
						if self.stories != stories {
							self.stories = stories
							self.tableView.reloadData()
							self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                            self.saveToDatabase(stories, by: storiesType)
						}
					}
				}
			} catch let error as NSError {
				print(error)
			}
		})
	}
	
    @objc private func getStories() {
        var storiesType: StoriesType = .new
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            storiesType = .new
            break
        case 1:
            storiesType = .top
            break
        case 2:
            storiesType = .best
            break
        default:
            break
        }
		
		loadFromDatabase(by: storiesType)
        loadFromServer(by: storiesType)
    }
    
    // MARK: - IBActions Methods
    
	@IBAction private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
		getStories()
	}
}

// MARK: - SFSafariViewControllerDelegate Methods

extension TableViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}

// MARK: - StoryTableViewCellDelegate Methods

extension TableViewController: StoryTableViewCellDelegate {
    
    func openUrl(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = UIColor.carrot
        safariVC.delegate = self
        present(safariVC, animated: true)
    }
}

