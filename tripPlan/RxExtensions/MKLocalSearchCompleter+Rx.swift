//
//  MKLocalSearchCompleter+Rx.swift
//  tripPlan
//
//  Created by 이순곤 on 2023/12/07.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa

class RxMKLocalSearchCompleterDelegateProxy: DelegateProxy<MKLocalSearchCompleter, MKLocalSearchCompleterDelegate>, DelegateProxyType, MKLocalSearchCompleterDelegate {

    static func registerKnownImplementations() {
        self.register { (localSearchCompleter) -> RxMKLocalSearchCompleterDelegateProxy in
            RxMKLocalSearchCompleterDelegateProxy(parentObject: localSearchCompleter, delegateProxy: self)
        }
    }

    

    static func currentDelegate(for object: MKLocalSearchCompleter) -> MKLocalSearchCompleterDelegate? {
        return object.delegate
    }

    

    static func setCurrentDelegate(_ delegate: MKLocalSearchCompleterDelegate?, to object: MKLocalSearchCompleter) {
        object.delegate = delegate
    }

}

extension Reactive where Base: MKLocalSearchCompleter {
    
    var delegate : DelegateProxy<MKLocalSearchCompleter, MKLocalSearchCompleterDelegate> {
        return RxMKLocalSearchCompleterDelegateProxy.proxy(for: self.base)
    }


    public var didUpdateResults: ControlEvent<[MKLocalSearchCompletion]> {
        let source = delegate
            .methodInvoked(#selector(MKLocalSearchCompleterDelegate.completerDidUpdateResults(_:)))
            .map { $0[0] as! MKLocalSearchCompleter }
            .map { $0.results }
        
        return ControlEvent(events: source)
    }
    
    public var queryFragment: Binder<String> {
            return Binder(self.base) { localSearchCompleter, query in
                localSearchCompleter.queryFragment = query
        }
    }
}
