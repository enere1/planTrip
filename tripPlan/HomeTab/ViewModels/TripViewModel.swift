//
//  TripViewModel.swift
//  tripPlan
//
//  Created by 이순곤 on 2024/01/12.
//

import Foundation
import RxCocoa
import RxSwift

class TripViewModel {
    
    var tripList = BehaviorRelay<[TripModel]>(value: [TripModel(orderNo: 0, category: "韓国",  placeImage: UIImage(named: "busan")!, title: "釜山", descriptionLabel: "", buttonIsEnabled: true),
        TripModel(orderNo: 1, category: "韓国", placeImage: UIImage(named: "seoul")!, title: "ソウル", descriptionLabel: "", buttonIsEnabled: true),
        TripModel(orderNo: 2, category: "日本", placeImage: UIImage(named: "tokyo")!, title: "東京", descriptionLabel: "", buttonIsEnabled: true),
        TripModel(orderNo: 3, category: "ヨーロッパ", placeImage: UIImage(named: "pari")!, title: "パリ", descriptionLabel: "", buttonIsEnabled: true),
        TripModel(orderNo: 4, category: "ヨーロッパ", placeImage: UIImage(named: "london")!, title: "ロンドン", descriptionLabel: "", buttonIsEnabled: true),
        TripModel(orderNo: 5, category: "東南アジア", placeImage: UIImage(named: "hanoi")!, title: "ハノイ", descriptionLabel: "", buttonIsEnabled: true),
        TripModel(orderNo: 6, category: "東南アジア", placeImage: UIImage(named: "danan")!, title: "ダナン", descriptionLabel: "", buttonIsEnabled: true),
        TripModel(orderNo: 7, category: "アメリカ", placeImage: UIImage(named: "newyork")!, title: "ニューヨーク", descriptionLabel: "", buttonIsEnabled: true),
        TripModel(orderNo: 8, category: "アメリカ", placeImage: UIImage(named: "califonia")!, title: "カリフォルニア", descriptionLabel: "", buttonIsEnabled: true),
        ])
}
