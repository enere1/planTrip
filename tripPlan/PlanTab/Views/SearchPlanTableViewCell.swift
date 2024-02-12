//
//  searchPlanTableViewCell.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/11/23.
//

import UIKit
import RxCocoa
import RxSwift

class SearchPlanTableViewCell: UITableViewCell {

    var disposeBag = DisposeBag()
    var tapSelectButtonAction: ((Int, Int, UIButton) -> Void)?
    var sectionIndex: Int?
    var rowIndex: Int?
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @IBAction func tapSelectButton(_ sender: UIButton) {
        tapSelectButtonAction?(sectionIndex!, rowIndex!, sender)
    }
}
