//
//  CommitsTableViewCell.swift
//  GithubAPITask
//
//  Created by Kapil Rathore on 05/04/17.
//  Copyright © 2017 Kapil Rathore. All rights reserved.
//

import UIKit

class CommitsTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var commitText: UILabel!
    @IBOutlet weak var authorName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
