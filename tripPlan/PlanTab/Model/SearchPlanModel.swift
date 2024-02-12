//
//  SearchPlanModel.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/11/24.
//

import Foundation
import UIKit

struct SearchPlanModel {
    let placeImage: UIImage
    let title: String
    let descriptionLabel: String
    var buttonIsEnabled: Bool
    let longitude: Double
    let latitude: Double
}


struct SearchPlanModelForTabView {
    let orderNo: Int
    let placeImage: UIImage
    let title: String
    let descriptionLabel: String
    var buttonIsEnabled: Bool
    let longitude: Double
    let latitude: Double
}
