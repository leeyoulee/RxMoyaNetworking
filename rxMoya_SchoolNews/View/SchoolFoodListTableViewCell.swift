//
//  SchoolFoodListTableViewCell.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 06/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit

class SchoolFoodListTableViewCell: UITableViewCell {
    static let identifier = String(describing: SchoolFoodListTableViewCell.self)
    
    @IBOutlet weak var foodServiceDateLabel: UILabel!
    @IBOutlet weak var foodCategoryLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
}
