import OKColor
import XCTest

final class OKColorTests: XCTestCase {
	private let accuracy = 0.05

	func testOkLabRoundtripRed() {
		let color = SRGB(1, 0, 0)
		let roundtrip = OkLab(srgb: color).srgb
		XCTAssertEqual(roundtrip.red, 1, accuracy: accuracy)
		XCTAssertEqual(roundtrip.green, 0, accuracy: accuracy)
		XCTAssertEqual(roundtrip.blue, 0, accuracy: accuracy)
	}

	func testOkLabRoundtripWhite() {
		let lab = OkLab(srgb: SRGB(1, 1, 1))
		XCTAssertEqual(lab.l, 1, accuracy: accuracy)
		XCTAssertEqual(lab.a, 0, accuracy: accuracy)
		XCTAssertEqual(lab.b, 0, accuracy: accuracy)
	}

	func testOkLabRoundtripBlack() {
		let lab = OkLab(srgb: SRGB(0, 0, 0))
		XCTAssertEqual(lab.l, 0, accuracy: accuracy)
	}

	func testOkLabRoundtripArbitraryColor() {
		let color = SRGB(0.3, 0.6, 0.9)
		let roundtrip = OkLab(srgb: color).srgb
		XCTAssertEqual(roundtrip.red, 0.3, accuracy: accuracy)
		XCTAssertEqual(roundtrip.green, 0.6, accuracy: accuracy)
		XCTAssertEqual(roundtrip.blue, 0.9, accuracy: accuracy)
	}

	func testOkLchRoundtripRed() {
		let color = SRGB(1, 0, 0)
		let roundtrip = OkLch(srgb: color).srgb
		XCTAssertEqual(roundtrip.red, 1, accuracy: accuracy)
		XCTAssertEqual(roundtrip.green, 0, accuracy: accuracy)
		XCTAssertEqual(roundtrip.blue, 0, accuracy: accuracy)
	}

	func testOkLchAchromaticHasZeroChroma() {
		let lch = OkLch(srgb: SRGB(0.5, 0.5, 0.5))
		XCTAssertEqual(lch.c, 0, accuracy: 0.01)
	}

	func testOkLabInterpolationUsesLinearChannels() {
		let midpoint = OkLab(srgb: SRGB(0, 0, 0)).lerp(to: OkLab(srgb: SRGB(1, 1, 1)), t: 0.5)
		XCTAssertEqual(midpoint.l, 0.5, accuracy: accuracy)
	}

	func testOkLchInterpolationUsesShortestHuePath() {
		let start = OkLch(0.5, 0.1, 350 * .pi / 180)
		let end = OkLch(0.5, 0.1, 10 * .pi / 180)
		let midpoint = start.lerp(to: end, t: 0.5)
		XCTAssertEqual(midpoint.h, 2 * .pi, accuracy: 0.001)
	}
}
