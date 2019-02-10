//
//  TableViewController.swift
//  Hacker News
//
//  Created by Sergey Fedorchukov on 07/02/2019.
//  Copyright © 2019 Sergey Fedorchukov. All rights reserved.
//

import UIKit
import SafariServices

class TableViewController: UITableViewController {

    // MARK: - IBOutlets and Connections
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Local Constants and Variables
    
    private var stories = [Int]()
    
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
        cell.loadData(by: stories[indexPath.row])
        return cell
    }
    
    // MARK: - User Defined Methods
    
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
        
        NetworkManager.shared.getStories(by: storiesType, completionHandler: { (data, response, error) -> Void in
            do {
                if let data = data, let stories = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Int] {
                    DispatchQueue.main.async {
                        self.stories = stories
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        })
    }
    
    // MARK: - IBActions Methods
    
    @IBAction private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if stories.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
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

