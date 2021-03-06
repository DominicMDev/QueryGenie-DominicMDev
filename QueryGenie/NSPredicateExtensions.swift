//
//  NSPredicateExtensions.swift
//
//  Created by Anthony Miller on 12/28/16.
//

import Foundation

public func && (left: NSPredicate, right: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(type: .and, subpredicates: [left, right])
}

public func || (left: NSPredicate, right: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(type: .or, subpredicates: [left, right])
}

prefix public func ! (left: NSPredicate) -> NSPredicate {
    return NSCompoundPredicate(type: .not, subpredicates: [left])
}
