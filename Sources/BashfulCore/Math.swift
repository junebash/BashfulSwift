//
//  File.swift
//  
//
//  Created by Jon Bash on 2020-10-09.
//

import Foundation


func - (lhs: Date, rhs: Date) -> TimeInterval {
	rhs.distance(to: lhs)
}
