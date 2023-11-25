//
//  SearchViewModel.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/11/23.
//

import Foundation
import TimelineTableViewCell
import RxCocoa
import RxSwift

class SearchViewModel {
    
    var textField: PublishSubject<String>
    var recommendList: BehaviorSubject<[SearchPlanModel]>

    init() {
        
        textField = PublishSubject()
        recommendList = BehaviorSubject<[SearchPlanModel]>(value: [
            SearchPlanModel(placeImage: "tokyoTower", title: "東京タワー", descriptionLabel: "観光スポット"),
            SearchPlanModel(placeImage: "asakusa", title: "浅草", descriptionLabel: "観光スポット")
        ])
        
        }
    }
    

