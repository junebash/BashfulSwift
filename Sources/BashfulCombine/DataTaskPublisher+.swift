//
//  File.swift
//  
//
//  Created by Jon Bash on 2020-10-10.
//

import Combine
import Foundation
import BashfulCore


extension URLSession.DataTaskPublisher {
	func validateStatusCode(
		_ statusCodes: IndexSet = IndexSet(integersIn: 200...299)
	) -> AnyPublisher<(data: Data?, response: HTTPURLResponse), NetworkError> {
		self.tryMap { (data, response) -> (data: Data, response: HTTPURLResponse) in
			guard let hr = response as? HTTPURLResponse, statusCodes ~= hr.statusCode else {
				throw NetworkError.badResponse(response)
			}
			return (data: data, response: hr)
		}.mapError(NetworkError.init)
		.eraseToAnyPublisher()
	}
}
