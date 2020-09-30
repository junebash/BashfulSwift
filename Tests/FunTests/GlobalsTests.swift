import XCTest
@testable import BashfulFun

class GlobalsTests: XCTestCase {
	func testID() {
		XCTAssertEqual(id(6), 6)
		XCTAssertEqual(id("hello"), "hello")
		let str = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
		XCTAssertEqual(id(UUID(uuidString: str)?.uuidString), str)
		XCTAssertEqual(
			[1, nil, 2, 3, nil, nil, 4, 5, 6, nil].compactMap(id),
			[1, 2, 3, 4, 5, 6])
		XCTAssertEqual(
			[[1, 2], [3, 4], [5]].flatMap(id),
			[1, 2, 3, 4, 5])
	}
}
