//
//  addButtonTableViewCell.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/11/23.
//

import UIKit
import RxCocoa
import RxSwift

class AddButtonTableViewCell: UITableViewCell {

    var disposeBag = DisposeBag()
    var addPlaceButtonAction: (() -> Void)?
    @IBOutlet weak var addMemoButton: UIButton!
    @IBOutlet weak var addPlaceButton: UIButton!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    @IBAction func tapAddPlaceButton(_ sender: UIButton) {
        addPlaceButtonAction?()
    }
    
}
