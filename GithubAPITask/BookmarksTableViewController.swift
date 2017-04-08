//
//  BookmarksTableViewController.swift
//  GithubAPITask
//
//  Created by Kapil Rathore on 08/04/17.
//  Copyright © 2017 Kapil Rathore. All rights reserved.
//

import UIKit

class BookmarksTableViewController: UITableViewController {
    
    var commitDetArr: [CommitDetails] = []
    var avatarDict: [String: Data] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 81.0
        self.tableView.sectionHeaderHeight = 30.0
        self.tableView.separatorStyle = .none
        
        loadData()
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
        // #warning Incomplete implementation, return the number of rows
        return commitDetArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commitCell", for: indexPath) as! CommitsTableViewCell
        
        let oneCommitDet = commitDetArr[indexPath.row]
        
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
    
    @IBAction func removeAll(_ sender: Any) {
        self.commitDetArr.removeAll()
        self.saveData()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let bookAction = UITableViewRowAction(style: .normal, title: "Remove") { (rowAction, indexPath) in
            // bookmark the row at indexPath here
            self.commitDetArr.remove(at: indexPath.row)
            self.saveData()
            self.tableView.reloadData()
        }
        bookAction.backgroundColor = .red
        
        return [bookAction]
    }
    
    func loadData() {
        var file : String {
            let manager = FileManager.default
            let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
            return url.appendingPathComponent("bookmarks").path
        }
        if let bookmarkTable = NSKeyedUnarchiver.unarchiveObject(withFile: file) as? [CommitDetails] {
            print(bookmarkTable.count)
            for item in bookmarkTable {
                self.commitDetArr.append(item)
            }
        }
        
        self.tableView.reloadData()
    }
    
    func saveData() {
        
        var filePath: String {
            let manager = FileManager.default
            let url = manager.urls(for: .documentDirectory , in: .userDomainMask).first!
            return url.appendingPathComponent("bookmarks").path
        }
        NSKeyedArchiver.archiveRootObject(self.commitDetArr, toFile: filePath)
    }
}
