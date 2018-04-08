//
//  LogCellTableViewCell.swift
//  IA
//
//  Created by Kenny Schlagel on 4/7/18.
//  Copyright © 2018 Kenny Schlagel. All rights reserved.
//

import UIKit

class LogCellTableViewCell: UITableViewCell {
    
    public static let reuseIdentifier: String = "LogCell"

    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
