//
//  SearchCountTableViewCell.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 07/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit

class SearchCountTableViewCell: UITableViewCell {
    static let identifier = String(describing: SearchCountTableViewCell.self)

    @IBOutlet weak var searchCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    
}
