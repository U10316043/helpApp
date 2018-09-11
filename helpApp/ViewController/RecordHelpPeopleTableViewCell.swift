//
//  RecordHelpPeopleTableViewCell.swift
//  helpApp
//
//  Created by xin on 2018/8/28.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit

class RecordHelpPeopleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var Item: UILabel!
    @IBOutlet weak var needHelpName: UILabel!
    @IBOutlet weak var missionStatus: UILabel!
    @IBOutlet weak var helpImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
