//
//  CommitDetails.swift
//  GithubAPITask
//
//  Created by Kapil Rathore on 05/04/17.
//  Copyright © 2017 Kapil Rathore. All rights reserved.
//

import Foundation

class CommitDetails: NSObject, NSCoding {
    
    struct Keys {
        static let commit = "commit"
        static let name = "name"
        static let message = "message"
        static let avatar_url = "avatar_url"
        static let author = "author"
    }
    
    var name: String?
    var message: String?
    var avatar_url: String?
    
    init(commitDetailDict: [String: AnyObject]) {
        
        if let commit = commitDetailDict[Keys.commit] as? [String: AnyObject] {
            if let author = commit[Keys.author] as? [String: AnyObject] {
                if let name = author[Keys.name] as? String {
                    self.name = name
                } else {
                    self.name = ""
                }
            } else {
                self.name = ""
            }
        } else {
            self.name = ""
        }
        
        if let commit = commitDetailDict[Keys.commit] as? [String: AnyObject] {
            if let message = commit[Keys.message] as? String {
                self.message = message
            } else {
                self.message = ""
            }
        } else {
            self.message = ""
        }
        
        if let author = commitDetailDict[Keys.author] as? [String: AnyObject] {
            if let avatar_url = author[Keys.avatar_url] as? String {
                self.avatar_url = avatar_url
            } else {
                self.avatar_url = ""
            }
        } else {
            self.avatar_url = ""
        }
    }
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Keys.name)
        aCoder.encode(message, forKey: Keys.message)
        aCoder.encode(avatar_url, forKey: Keys.avatar_url)
    }
    
    required init(coder unarchiver: NSCoder) {
        name = unarchiver.decodeObject(forKey: Keys.name) as? String
        message = unarchiver.decodeObject(forKey: Keys.message) as? String
        avatar_url = unarchiver.decodeObject(forKey: Keys.avatar_url) as? String
        
        super.init()
    }
}
