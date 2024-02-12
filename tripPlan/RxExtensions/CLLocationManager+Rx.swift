//
//  CLLocationManager+Rx.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/12/16.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>,DelegateProxyType, CLLocationManagerDelegate {
    static func registerKnownImplementations() {
        <#code#>
    }
    
    static func currentDelegate(for object: CLLocationManager) -> CLLocationManagerDelegate? {
        <#code#>
    }
    
    static func setCurrentDelegate(_ delegate: CLLocationManagerDelegate?, to object: CLLocationManager) {
        <#code#>
    }
    
    
}
