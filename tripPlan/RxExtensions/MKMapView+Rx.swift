//
//  MKMapView+Rx.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/12/17.
//

import Foundation
import MapKit
import RxCocoa
import RxSwift

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    static func registerKnownImplementations() {
        self.register { (mapView) -> RxMKMapViewDelegateProxy in
            RxMKMapViewDelegateProxy(parentObject: mapView, delegateProxy: self)
        }
    }
    
    static func currentDelegate(for object: MKMapView) -> MKMapViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: MKMapViewDelegate?, to object: MKMapView) {
        object.delegate = delegate
    }
    
}

extension Reactive where Base: MKMapView {
    
    var delegate : DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: self.base)
    }
    
    
    func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
        
        return RxMKMapViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
    
}
