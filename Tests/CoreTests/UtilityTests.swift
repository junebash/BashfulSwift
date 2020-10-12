import XCTest
@testable import BashfulCore


class UtilityTests: XCTestCase {
	func testResultTryMap() throws {
		struct MockError: Error {}

		let int: Int? = 0
		let result = Result<Int?, NetworkError>.success(int)
		let newResult = result.tryMap { i throws -> String in
			if let x = i.map(String.init) {
				return x
			} else {
				throw MockError()
			}
		}
		let str = try XCTUnwrap(try newResult.get())
		XCTAssertEqual(str, "0")
	}
}
