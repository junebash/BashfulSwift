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

	func tryMap<NewSuccess>(
		_ transform: (Success) throws -> NewSuccess
	) -> Result<NewSuccess, Error> {
		Result<NewSuccess, Error> {
			try transform(try self.get())
		}
	}
}

public extension Result where Success == Data, Failure == NetworkError {
	init(
		data: Data?,
		response: URLResponse?,
		error: Error? = nil,
		allowedStatusCodes: IndexSet = IndexSet(integersIn: 200...299)
	) {
		self = {
			if let e = error { return .failure(NetworkError(e)) }
			guard let r = response else { return .failure(.noResponse) }
			guard
				let httpResponse = r as? HTTPURLResponse,
				allowedStatusCodes ~= httpResponse.statusCode
			else { return .failure(.badResponse(r)) }
			guard let d = data else { return .failure(.noData) }

			return .success(d)
		}()
	}
}
