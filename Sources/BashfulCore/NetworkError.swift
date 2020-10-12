//
//  File.swift
//  
//
//  Created by Jon Bash on 2020-10-09.
//

import Foundation


public enum NetworkError: Error {
	case urlError(URLError)
	case badURL(URL)
	case badURLString(String)
	case decodeError(DecodingError)
	case encodeError(EncodingError)
	case badResponse(URLResponse)
	case noResponse
	case noData
	case other(Error)
	case unknown

	public init(_ e: Error) {
		switch e {
		case let ne as NetworkError:
			self = ne
		case let ue as URLError:
			if let url = ue.failingURL {
				self = .badURL(url)
			} else if let urlString = ue.failureURLString {
				self = .badURLString(urlString)
			} else {
				self = .urlError(ue)
			}
		case let de as DecodingError:
			self = .decodeError(de)
		case let ee as EncodingError:
			self = .encodeError(ee)
		default:
			self = .other(e)
		}
	}
}


