//
//  File.swift
//  
//
//  Created by Jon Bash on 2020-10-02.
//

import Foundation


public extension Result {
	/// If `self == .failure`, returns the wrapped `Failure` value.
	var error: Failure? {
		if case .failure(let error) = self {
			return error
		} else {
			return nil
		}
	}
}
