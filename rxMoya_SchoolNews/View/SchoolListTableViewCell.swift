//
//  SchoolListTableViewCell.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 06/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import RxSwift

class SchoolListTableViewCell: UITableViewCell {
    static let identifier = String(describing: SchoolListTableViewCell.self)
    
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolAddressLabel: UILabel!
    @IBOutlet weak var schoolRegistButton: UIButton!
    
    let disposeBag = DisposeBag()
    var buttonActionHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.schoolRegistButton.rx.tap.subscribe(onNext: { [weak self] value in
            guard let `self` = self else { return }
            self.buttonActionHandler?()
        }).disposed(by: disposeBag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
}
