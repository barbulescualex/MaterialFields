//
//  Extensions.swift
//  MaterialFieldsProgrammaticExample
//
//  Created by Alex Barbulescu on 2019-06-01.
//  Copyright © 2019 alex. All rights reserved.
//

import Foundation

extension CaseIterable where AllCases.Element: Equatable {
    static func make(index: Int) -> Self? { //get the key from the case index
        let a = Self.allCases
        if (index > a.count - 1) { return nil } //out of range
        return a[a.index(a.startIndex, offsetBy: index)]
    }
    
    func index() -> Int { //get the index from the case
        let a = Self.allCases
        return a.distance(from: a.startIndex, to: a.firstIndex(of: self)!)
    }
}
