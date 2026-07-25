import OkColor
import XCTest

final class OkColorTests: XCTestCase {
	func testSRGBTransferMatchesDartCases() {
		let cases: [(SRGB, LinearSRGB)] = [
			(SRGB(0, 0, 0), LinearSRGB(0, 0, 0)),
			(SRGB(1, 1, 1), LinearSRGB(1, 1, 1)),
			(SRGB(0.5, 0.5, 0.5), LinearSRGB(0.214041, 0.214041, 0.214041)),
			(SRGB(0.7, 0.2, 0.3), LinearSRGB(0.447988, 0.033105, 0.073239)),
			(SRGB(0.1, 0.8, 0.6), LinearSRGB(0.010023, 0.603827, 0.318547)),
		]

		for (rgb, expectedLinear) in cases {
			assertLinear(rgb.linear, expectedLinear, accuracy: 1e-6)
			assertSRGB(rgb.linear.srgb, rgb, accuracy: 1e-6)
		}
	}

	func testOkLabMatchesDartCases() {
		let cases: [(SRGB, OkLab)] = [
			(SRGB(0, 0, 0), OkLab(0, 0, 0)),
			(SRGB(1, 1, 1), OkLab(1, 0, 0)),
			(SRGB(1, 0, 0), OkLab(0.627955, 0.224863, 0.125846)),
			(SRGB(0, 1, 0), OkLab(0.866440, -0.233887, 0.179498)),
			(SRGB(0, 0, 1), OkLab(0.452014, -0.032457, -0.311528)),
			(SRGB(0.7, 0.2, 0.3), OkLab(0.519632, 0.158814, 0.03801)),
			(SRGB(0.2, 0.4, 0.8), OkLab(0.532483, -0.022512, -0.16634)),
		]

		for (rgb, expectedLab) in cases {
			let lab = OkLab(srgb: rgb)
			assertOkLab(lab, expectedLab, accuracy: 1e-5)
			assertSRGB(lab.srgb, rgb, accuracy: 1e-5)
		}
	}

	func testOkLchMatchesDartCases() {
		let cases: [(SRGB, OkLch)] = [
			(SRGB(0, 0, 0), OkLch(0, 0, 0)),
			(SRGB(1, 0, 0), OkLch(0.627955377, 0.257683247, 0.510227621)),
			(SRGB(0, 1, 0), OkLch(0.866439581, 0.294827133, 2.487012625)),
			(SRGB(0, 0, 1), OkLch(0.452013701, 0.313214391, -1.674608111)),
			(SRGB(0.2, 0.4, 0.8), OkLch(0.532482564, 0.167865545, -1.705307722)),
		]

		for (rgb, expectedLch) in cases {
			let lch = OkLch(srgb: rgb)
			assertOkLch(lch, expectedLch, accuracy: 1e-6)
			assertSRGB(lch.srgb, rgb, accuracy: 1e-5)
		}
	}

	func testOkHslMatchesDartCases() {
		let cases: [(SRGB, OkHsl)] = [
			(SRGB(0, 0, 0), OkHsl(0, 0, 0)),
			(SRGB(1, 1, 1), OkHsl(0, 0, 1)),
			(SRGB(1, 0, 0), OkHsl(0.081205, 1, 0.568085)),
			(SRGB(0, 1, 0), OkHsl(0.395820, 1, 0.844529)),
			(SRGB(0, 0, 1), OkHsl(0.733478, 1, 0.366565)),
			(SRGB(0.7, 0.2, 0.3), OkHsl(0.037391, 0.775071, 0.443573)),
			(SRGB(0.2, 0.4, 0.8), OkHsl(0.728592, 0.825065, 0.458283)),
		]

		for (rgb, expectedHsl) in cases {
			let hsl = OkHsl(srgb: rgb)
			assertOkHsl(hsl, expectedHsl, accuracy: 1e-5)
			assertSRGB(hsl.srgb, rgb, accuracy: 1e-5)
		}
	}

	func testOkHsvMatchesDartCases() {
		let cases: [(SRGB, OkHsv, Double)] = [
			(SRGB(0, 0, 0), OkHsv(0, 0, 0), 1e-5),
			(SRGB(1, 1, 1), OkHsv(0, 0, 1), 1e-5),
			(SRGB(1, 0, 0), OkHsv(0.081205, 1, 1), 1e-3),
			(SRGB(0, 1, 0), OkHsv(0.395820, 1, 1), 1e-5),
			(SRGB(0, 0, 1), OkHsv(0.733478, 0.999991, 1), 1e-5),
			(SRGB(0.7, 0.2, 0.3), OkHsv(0.037391, 0.834492, 0.711834), 1e-5),
			(SRGB(0.2, 0.4, 0.8), OkHsv(0.728592, 0.782249, 0.807227), 1e-5),
		]

		for (rgb, expectedHsv, accuracy) in cases {
			let hsv = OkHsv(srgb: rgb)
			assertOkHsv(hsv, expectedHsv, accuracy: accuracy)
			assertSRGB(hsv.srgb, rgb, accuracy: accuracy)
		}
	}

	func testGamutHelpersMatchDartCases() {
		let saturationCases: [(Double, Double, Double)] = [
			(1, 0, 0.405391),
			(-0.5, 0.866025, 0.237417),
			(0, -1, 0.655372),
			(0.707107, -0.707107, 0.492243),
		]
		for (a, b, expected) in saturationCases {
			XCTAssertEqual(OkGamut.computeMaxSaturation(a, b), expected, accuracy: 1e-6)
		}

		let cusp = OkGamut.findCusp(1, 0)
		XCTAssertEqual(cusp.l, 0.647704, accuracy: 1e-6)
		XCTAssertEqual(cusp.c, 0.262574, accuracy: 1e-6)

		let intersection = OkGamut.findGamutIntersection(1, 0, l1: 0.5, c1: 0.1, l0: 0.7, cusp: (0.8, 0.3))
		XCTAssertEqual(intersection, 1.5, accuracy: 1e-6)

		XCTAssertEqual(OkGamut.toe(0.5), 0.421141, accuracy: 1e-6)
		XCTAssertEqual(OkGamut.toeInverse(0.5), 0.568838, accuracy: 1e-6)
	}

	func testInterpolationAndHarmonyHelpersMatchDartBehavior() {
		let start = OkLch(0.5, 0.1, 350 * .pi / 180)
		let end = OkLch(0.5, 0.1, 10 * .pi / 180)
		XCTAssertEqual(start.lerp(to: end, t: 0.5).h, 0, accuracy: 0.001)

		XCTAssertEqual(OkGamut.computeMaxSaturation(0, 0).isNaN, true)
		XCTAssertEqual(OkLch(0.5, 0.2, 0.3).rotated(180).h, 0.3 + .pi, accuracy: 1e-6)
		XCTAssertEqual(OkLch(0.5, 0.2, 0.3).analogous(count: 2).count, 5)
		XCTAssertEqual(OkColor.gradient(from: SRGB(0, 0, 0), to: SRGB(1, 1, 1), count: 5).count, 5)
	}

	private func assertSRGB(_ actual: SRGB, _ expected: SRGB, accuracy: Double, file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertEqual(actual.red, expected.red, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.green, expected.green, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.blue, expected.blue, accuracy: accuracy, file: file, line: line)
	}

	private func assertLinear(_ actual: LinearSRGB, _ expected: LinearSRGB, accuracy: Double, file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertEqual(actual.red, expected.red, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.green, expected.green, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.blue, expected.blue, accuracy: accuracy, file: file, line: line)
	}

	private func assertOkLab(_ actual: OkLab, _ expected: OkLab, accuracy: Double, file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertEqual(actual.l, expected.l, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.a, expected.a, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.b, expected.b, accuracy: accuracy, file: file, line: line)
	}

	private func assertOkLch(_ actual: OkLch, _ expected: OkLch, accuracy: Double, file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertEqual(actual.l, expected.l, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.c, expected.c, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.h, expected.h, accuracy: accuracy, file: file, line: line)
	}

	private func assertOkHsl(_ actual: OkHsl, _ expected: OkHsl, accuracy: Double, file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertEqual(actual.h, expected.h, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.s, expected.s, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.l, expected.l, accuracy: accuracy, file: file, line: line)
	}

	private func assertOkHsv(_ actual: OkHsv, _ expected: OkHsv, accuracy: Double, file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertEqual(actual.h, expected.h, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.s, expected.s, accuracy: accuracy, file: file, line: line)
		XCTAssertEqual(actual.v, expected.v, accuracy: accuracy, file: file, line: line)
	}
}
