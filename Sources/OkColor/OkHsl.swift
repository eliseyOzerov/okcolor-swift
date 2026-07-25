import Foundation

public extension OkHsl {
	init(srgb: SRGB) {
		if srgb.red <= 0 && srgb.green <= 0 && srgb.blue <= 0 {
			self.init(0, 0, 0)
			return
		}

		let lab = OkLab(srgb: srgb)
		let c = sqrt(lab.a * lab.a + lab.b * lab.b)
		let l = OkColorModuleToe(lab.l)
		guard c > 1e-10 else {
			self.init(0, 0, l)
			return
		}

		let a_ = lab.a / c
		let b_ = lab.b / c
		let h = 0.5 + 0.5 * atan2(-lab.b, -lab.a) / .pi
		let cs = getCs(lab.l, a_, b_)
		let mid = 0.8
		let midInv = 1.25
		let s: Double

		if c < cs.cMid {
			let k1 = mid * cs.c0
			let k2 = 1 - k1 / cs.cMid
			let t = c / (k1 + k2 * c)
			s = t * mid
		} else {
			let k0 = cs.cMid
			let k1 = (1 - mid) * cs.cMid * cs.cMid * midInv * midInv / cs.c0
			let k2 = 1 - k1 / (cs.cMax - cs.cMid)
			let t = (c - k0) / (k1 + k2 * (c - k0))
			s = mid + (1 - mid) * t
		}

		if srgb.red == srgb.green && srgb.green == srgb.blue {
			self.init(0, 0, l)
		} else {
			self.init(okPositiveModulo(h, 1), s, l)
		}
	}

	var srgb: SRGB {
		if l == 1 {
			return SRGB(1, 1, 1)
		}
		if l == 0 {
			return SRGB(0, 0, 0)
		}

		let a_ = cos(2 * .pi * h)
		let b_ = sin(2 * .pi * h)
		let lightness = OkColorModuleToeInv(l)
		let cs = getCs(lightness, a_, b_)
		let mid = 0.8
		let midInv = 1.25
		let chroma: Double

		if s < mid {
			let t = midInv * s
			let k1 = mid * cs.c0
			let k2 = 1 - k1 / cs.cMid
			chroma = t * k1 / (1 - k2 * t)
		} else {
			let t = (s - mid) / (1 - mid)
			let k0 = cs.cMid
			let k1 = (1 - mid) * cs.cMid * cs.cMid * midInv * midInv / cs.c0
			let k2 = 1 - k1 / (cs.cMax - cs.cMid)
			chroma = k0 + t * k1 / (1 - k2 * t)
		}

		return OkLab(lightness, chroma * a_, chroma * b_).srgb
	}

	func withHue(_ h: Double) -> OkHsl {
		OkHsl(h, s, l)
	}

	func withSaturation(_ s: Double) -> OkHsl {
		OkHsl(h, s, l)
	}

	func withLightness(_ l: Double) -> OkHsl {
		OkHsl(h, s, l)
	}

	func darker(_ percentage: Double) -> OkHsl {
		withLightness(okLerp(l, 0, percentage))
	}

	func lighter(_ percentage: Double) -> OkHsl {
		withLightness(okLerp(l, 1, percentage))
	}

	func saturate(_ percentage: Double) -> OkHsl {
		withSaturation(okLerp(s, 1, percentage))
	}

	func desaturate(_ percentage: Double) -> OkHsl {
		withSaturation(okLerp(s, 0, percentage))
	}

	func rotated(_ degrees: Double) -> OkHsl {
		withHue(okPositiveModulo(h + degrees / 360, 1))
	}

	func complementary() -> OkHsl {
		rotated(180)
	}

	func splitComplementary() -> [OkHsl] {
		[rotated(150), self, rotated(210)]
	}

	func triadic() -> [OkHsl] {
		[rotated(120), self, rotated(240)]
	}

	func tetradic() -> [OkHsl] {
		[self, complementary(), rotated(90), rotated(270)]
	}

	func analogous(count: Int = 2, angle: Double = 30) -> [OkHsl] {
		guard count > 0 else {
			return [self]
		}
		return (1 ... count).reversed().map { rotated(angle * Double($0)) } + [self] + (1 ... count).map { rotated(-angle * Double($0)) }
	}

	func shades(count: Int = 5) -> [OkHsl] {
		guard count > 1 else {
			return count == 1 ? [self] : []
		}
		return (0 ..< count).map { darker(Double($0) / Double(count - 1)) }
	}

	func tints(count: Int = 5) -> [OkHsl] {
		guard count > 1 else {
			return count == 1 ? [self] : []
		}
		return (0 ..< count).map { lighter(Double($0) / Double(count - 1)) }
	}

	func lerp(to other: OkHsl, t: Double, shortestPath: Bool = true) -> OkHsl {
		OkHsl(
			lerpAngle(h, other.h, t, shortestPath: shortestPath),
			okLerp(s, other.s, t),
			okLerp(l, other.l, t)
		)
	}
}
