//
//  CommitsTableViewController.swift
//  GithubAPITask
//
//  Created by Kapil Rathore on 05/04/17.
//  Copyright © 2017 Kapil Rathore. All rights reserved.
//

import UIKit

class CommitsTableViewController: UITableViewController {
    
    let loadingView: UIView = UIView()
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var commitDetArr: [CommitDetails] = []
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
        
        self.tableView.rowHeight = 81.0
        self.tableView.sectionHeaderHeight = 30.0
        self.tableView.separatorStyle = .none
        
        downloadData()
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
        return self.commitDetArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commitCell", for: indexPath) as! CommitsTableViewCell
        
        let oneCommitDet = commitDetArr[indexPath.row]
        // Configure the cell...
        cell.authorName.text = oneCommitDet.name!
        cell.commitText.text = oneCommitDet.message!
        cell.avatarImg.image = UIImage(data: avatarDict[oneCommitDet.name!]!)
        
        cell.avatarImg.layer.borderWidth = 1
        cell.avatarImg.layer.masksToBounds = false
        cell.avatarImg.layer.borderColor = UIColor.black.cgColor
        cell.avatarImg.layer.cornerRadius = cell.avatarImg.frame.height/2
        cell.avatarImg.clipsToBounds = true
        
        return cell
    }
    
    // Function to download and render the avatar image.
    func downloadImage(_ imageUrl: String) -> Data? {
        let url = URL(string: imageUrl)
        let data = try? Data(contentsOf: url!)
        return data
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
