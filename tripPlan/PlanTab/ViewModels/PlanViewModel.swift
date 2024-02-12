//
//  PlanViewModel.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/11/20.
//

import Foundation
import TimelineTableViewCell
import RxCocoa
import RxSwift
class PlanViewModel {
    
    var data = BehaviorRelay<[Int: [(TimelinePoint?, UIColor?, String?, String?, String?, [String]?, String?)]]>(value: [0:[]])
    init() {
        
    }
}
