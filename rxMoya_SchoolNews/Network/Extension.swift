//
//  Extension.swift
//  rxMoya_SchoolNews
//
//  Created by 이유리 on 10/02/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

extension Date {
    /// 이전 달을 나타내는 Date 값
    var previousMonth: Date {
        return Calendar.current.date(byAdding: DateComponents(month: -1), to: self)!
    }
    
    /// 다음 달을 나타내는 Date 값
    var nextMonth: Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1), to: self)!
    }
    
    /// 해당 달의 첫 날을 나타내는   Date 값
    var startOfMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    /// 해당 달의 마지막 날을 나타내는   Date 값
    var endOfMonth: Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth)!
    }
}
