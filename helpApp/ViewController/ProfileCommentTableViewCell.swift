//
//  ProfileCommentTableViewCell.swift
//  helpApp
//
//  Created by xin on 2018/9/7.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit

class ProfileCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userHeart: UIImageView!
    @IBOutlet weak var userHelpNeed: UILabel!
    @IBOutlet weak var userMessage: UITextView!
    @IBOutlet weak var userPicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
