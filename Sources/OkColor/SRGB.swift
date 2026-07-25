import Foundation

public extension SRGB {
	/// Converts gamma-encoded sRGB channels to linear sRGB channels.
	var linear: LinearSRGB {
		LinearSRGB(
			srgbToLinear(red),
			srgbToLinear(green),
			srgbToLinear(blue)
		)
	}

	var okLab: OkLab {
		OkLab(srgb: self)
	}

	var okLch: OkLch {
		OkLch(srgb: self)
	}

	var okHsl: OkHsl {
		OkHsl(srgb: self)
	}

	var okHsv: OkHsv {
		OkHsv(srgb: self)
	}

	func lerp(to other: SRGB, t: Double) -> SRGB {
		SRGB(
			okLerp(red, other.red, t),
			okLerp(green, other.green, t),
			okLerp(blue, other.blue, t)
		)
	}

	func darker(_ percentage: Double) -> SRGB {
		okHsl.darker(percentage).srgb
	}

	func lighter(_ percentage: Double) -> SRGB {
		okHsl.lighter(percentage).srgb
	}

	func saturate(_ percentage: Double) -> SRGB {
		okHsl.saturate(percentage).srgb
	}

	func desaturate(_ percentage: Double) -> SRGB {
		okHsl.desaturate(percentage).srgb
	}

	func rotated(_ degrees: Double) -> SRGB {
		okHsl.rotated(degrees).srgb
	}

	func complementary() -> SRGB {
		okHsl.complementary().srgb
	}

	func splitComplementary() -> [SRGB] {
		okHsl.splitComplementary().map(\.srgb)
	}

	func triadic() -> [SRGB] {
		okHsl.triadic().map(\.srgb)
	}

	func tetradic() -> [SRGB] {
		okHsl.tetradic().map(\.srgb)
	}

	func analogous(count: Int = 2, angle: Double = 30) -> [SRGB] {
		okHsl.analogous(count: count, angle: angle).map(\.srgb)
	}

	func shades(count: Int = 5) -> [SRGB] {
		okHsl.shades(count: count).map(\.srgb)
	}

	func tints(count: Int = 5) -> [SRGB] {
		okHsl.tints(count: count).map(\.srgb)
	}
}
