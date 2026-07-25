import Foundation

public extension OkLch {
	/// Creates an OkLch value from an OkLab value.
	init(oklab lab: OkLab) {
		let c = sqrt(lab.a * lab.a + lab.b * lab.b)
		let h = (abs(lab.a) < 1e-6 && abs(lab.b) < 1e-6) ? 0 : atan2(lab.b, lab.a)
		self.init(lab.l, c, h)
	}

	/// Creates an OkLch value from gamma-encoded sRGB channels.
	init(srgb: SRGB) {
		self.init(oklab: OkLab(srgb: srgb))
	}

	/// Converts this OkLch value to OkLab.
	var oklab: OkLab {
		OkLab(l, c * cos(h), c * sin(h))
	}

	/// Converts this OkLch value to gamma-encoded sRGB channels, clamped to the displayable sRGB gamut.
	var srgb: SRGB {
		oklab.srgb
	}

	var hue: OkHue {
		let radians = okPositiveModulo(h, 2 * .pi)
		return OkHue.hues.min { lhs, rhs in
			abs(radians - lhs.value.degreesToRadians) < abs(radians - rhs.value.degreesToRadians)
		}?.key ?? .pink
	}

	func withLightness(_ l: Double) -> OkLch {
		OkLch(l, c, h)
	}

	func withChroma(_ c: Double) -> OkLch {
		OkLch(l, c, h)
	}

	func withHue(_ h: Double) -> OkLch {
		OkLch(l, c, h)
	}

	func darker(_ percentage: Double) -> OkLch {
		withLightness(okLerp(l, 0, percentage))
	}

	func lighter(_ percentage: Double) -> OkLch {
		withLightness(okLerp(l, 1, percentage))
	}

	func saturate(_ percentage: Double) -> OkLch {
		withChroma(okLerp(c, 1, percentage))
	}

	func desaturate(_ percentage: Double) -> OkLch {
		withChroma(okLerp(c, 0, percentage))
	}

	func rotated(_ degrees: Double) -> OkLch {
		withHue(okPositiveModulo(h + degrees.degreesToRadians, 2 * .pi))
	}

	func complementary() -> OkLch {
		rotated(180)
	}

	func splitComplementary() -> [OkLch] {
		[rotated(150), self, rotated(210)]
	}

	func triadic() -> [OkLch] {
		[rotated(120), self, rotated(240)]
	}

	func tetradic() -> [OkLch] {
		[self, complementary(), rotated(90), rotated(270)]
	}

	func analogous(count: Int = 2, angle: Double = 30) -> [OkLch] {
		guard count > 0 else {
			return [self]
		}
		return (1 ... count).reversed().map { rotated(angle * Double($0)) } + [self] + (1 ... count).map { rotated(-angle * Double($0)) }
	}

	func shades(count: Int = 5) -> [OkLch] {
		guard count > 1 else {
			return count == 1 ? [self] : []
		}
		return (0 ..< count).map { darker(Double($0) / Double(count - 1)) }
	}

	func tints(count: Int = 5) -> [OkLch] {
		guard count > 1 else {
			return count == 1 ? [self] : []
		}
		return (0 ..< count).map { lighter(Double($0) / Double(count - 1)) }
	}

	/// Interpolates to another OkLch value.
	func lerp(to other: OkLch, t: Double, shortestPath: Bool = true) -> OkLch {
		OkLch(
			okLerp(l, other.l, t),
			okLerp(c, other.c, t),
			lerpAngle(h, other.h, t, range: 2 * .pi, shortestPath: shortestPath)
		)
	}

	static func + (lhs: OkLch, rhs: OkLch) -> OkLch {
		OkLch(lhs.l + rhs.l, lhs.c + rhs.c, okPositiveModulo(lhs.h + rhs.h, 2 * .pi))
	}

	static func - (lhs: OkLch, rhs: OkLch) -> OkLch {
		OkLch(lhs.l - rhs.l, lhs.c - rhs.c, okPositiveModulo(lhs.h - rhs.h, 2 * .pi))
	}
}
