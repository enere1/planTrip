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

    init() {
        
        textField = PublishSubject()
        
        }
    }
    

