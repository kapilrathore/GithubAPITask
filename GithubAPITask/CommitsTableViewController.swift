//
//  CommitsTableViewController.swift
//  GithubAPITask
//
//  Created by Kapil Rathore on 05/04/17.
//  Copyright © 2017 Kapil Rathore. All rights reserved.
//

import UIKit

class CommitsTableViewController: UITableViewController, UISearchResultsUpdating{
    
    var searchController: UISearchController!
    
    let loadingView: UIView = UIView()
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var commitDetArr: [CommitDetails] = []
    var bookmarkedCommitDetArr: [CommitDetails] = []
    var filterCommitDetArr: [CommitDetails] = []
    var authorCommitDict: [String: [CommitDetails]] = [:]
    var authorArr: [String] = []
    var avatarDict: [String: Data] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loading View Stating
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor.black
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        self.view.addSubview(loadingView)
        actInd.startAnimating()
        
        // search bar implementaion
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        self.tableView.rowHeight = 81.0
        self.tableView.sectionHeaderHeight = 30.0
        self.tableView.separatorStyle = .none
        
        downloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.bookmarkedCommitDetArr.removeAll()
        loadData()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filterCommitDetArr = commitDetArr.filter { commitDet in
            var commitDetName = ""
            var commitDetMsg = ""
            
            if commitDet.name!.lowercased().contains(searchText.lowercased()) == true {
                commitDetName = commitDet.name!
            }
            if commitDet.message!.lowercased().contains(searchText.lowercased()) == true {
                commitDetMsg = commitDet.message!
            }
            
            let searchString = "\(commitDetName) \(commitDetMsg)"
            return searchString.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterCommitDetArr.count
        }
        return commitDetArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commitCell", for: indexPath) as! CommitsTableViewCell
        
        let oneCommitDet: CommitDetails
        
        if searchController.isActive && searchController.searchBar.text != "" {
            oneCommitDet = filterCommitDetArr[indexPath.row]
        } else {
            oneCommitDet = commitDetArr[indexPath.row]
        }
        
        // Configure the cell...
        cell.authorName.text = oneCommitDet.name!
        cell.commitText.text = oneCommitDet.message!
        if let avatar = avatarDict[oneCommitDet.name!] {
            cell.avatarImg.image = UIImage(data: avatar)
        }
        cell.avatarImg.layer.borderWidth = 1
        cell.avatarImg.layer.masksToBounds = false
        cell.avatarImg.layer.borderColor = UIColor.black.cgColor
        cell.avatarImg.layer.cornerRadius = cell.avatarImg.frame.height/2
        cell.avatarImg.clipsToBounds = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let oneCommitDet: CommitDetails
        
        if searchController.isActive && searchController.searchBar.text != "" {
            oneCommitDet = filterCommitDetArr[indexPath.row]
        } else {
            oneCommitDet = commitDetArr[indexPath.row]
        }
        let bookAction = UITableViewRowAction(style: .normal, title: "Bookmark") { (rowAction, indexPath) in
            // bookmark the row at indexPath here
            self.bookmarkedCommitDetArr.append(oneCommitDet)
            self.saveData()
        }
        bookAction.backgroundColor = .blue
        
        return [bookAction]
    }
    
    @IBAction func viewBookmarks(_ sender: Any) {
        
        let bookmarkVC = storyboard?.instantiateViewController(withIdentifier: "BookmarkVC") as? BookmarksTableViewController

        bookmarkVC?.avatarDict = self.avatarDict
        
        self.navigationController?.pushViewController(bookmarkVC!, animated: true)
    }

    // Function to download and render the avatar image.
    func downloadImage(_ imageUrl: String) -> Data? {
        let url = URL(string: imageUrl)
        let data = try? Data(contentsOf: url!)
        return data
    }
    
    func saveData() {
        var filePath: String {
            let manager = FileManager.default
            let url = manager.urls(for: .documentDirectory , in: .userDomainMask).first!
            return url.appendingPathComponent("bookmarks").path
        }
        NSKeyedArchiver.archiveRootObject(self.bookmarkedCommitDetArr, toFile: filePath)
    }
    
    
    
    func loadData() {
        var file : String {
            let manager = FileManager.default
            let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
            return url.appendingPathComponent("bookmarks").path
        }
        if let bookmarkTable = NSKeyedUnarchiver.unarchiveObject(withFile: file) as? [CommitDetails] {
            for item in bookmarkTable {
                self.bookmarkedCommitDetArr.append(item)
            }
        }
    }
    
    // Download the JSON data and render it on our app's TableView
    func downloadData() {
        let url = "https://api.github.com/repos/rails/rails/commits"
        let networkkOp = NetworkOperation(url: URL(string: url)!)
        
        networkkOp.downloadJSONFromURL(completion: {
            
            ( allDict) in
            
            if allDict != nil {
                DispatchQueue.main.async {
                    
                    let allCommitDict = allDict!
                    
                    for oneCommit in allCommitDict {
                        let commitDet = CommitDetails(commitDetailDict: oneCommit)
                        self.commitDetArr.append(commitDet)
                        
                        if !self.authorArr.contains(commitDet.name!) {
                            self.authorArr.append(commitDet.name!)
                        }
                        
                        print(self.authorArr)
                    }
                    
                    for commitDet in self.commitDetArr {
                        if self.avatarDict[commitDet.name!] != nil {
                            // do nothing
                        } else {
                            self.avatarDict[commitDet.name!] = self.downloadImage(commitDet.avatar_url!)
                        }
                    }
                    
                    self.commitDetArr.sort(by: { $0.name!.localizedCaseInsensitiveCompare($1.name!) == ComparisonResult.orderedAscending })
                    
                    // Stop Loading view and reload tableView
                    self.actInd.stopAnimating()
                    self.loadingView.removeFromSuperview()
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = .singleLine
                }
            }
        })
    }
}
