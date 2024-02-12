//
//  FSCalendar+Rx.swift
//  tripPlan
//
//  Created by 이순곤 on 2024/01/18.
//

import Foundation
import FSCalendar
import RxCocoa
import RxSwift

DelegateProxy<FSCalendar, FSCalendarDelegateAppearance

class RxFSCalendarViewDelegateProxy: DelegateProxy<FSCalendar, FSCalendarDelegate>, DelegateProxyType, FSCalendarDelegate {
    static func registerKnownImplementations() {
        self.register { (calendar) -> RxFSCalendarViewDelegateProxy in
            RxFSCalendarViewDelegateProxy(parentObject: calendar, delegateProxy: self)
        }
    }
    
    static func currentDelegate(for object: FSCalendar) -> FSCalendarDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: FSCalendarDelegate?, to object: FSCalendar) {
        object.delegate = delegate
    }
    
}

extension Reactive where Base: FSCalendar {
    
    var delegate : DelegateProxy<FSCalendar, FSCalendarDelegate> {
        return RxFSCalendarViewDelegateProxy.proxy(for: self.base)
    }

    func setDelegate(_ delegate: FSCalendarDelegate) -> Disposable {
        
        return RxFSCalendarViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
    
    var didSelect: Observable<Date> {
        return delegate.methodInvoked(#selector(FSCalendarDelegate.calendar(_:didSelect:at:)))
            .map { parameter in
                return parameter[1] as? Date ?? Date()
            }
    }
}
