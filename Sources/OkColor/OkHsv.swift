import Foundation

public extension OkHsv {
	init(srgb: SRGB) {
		if srgb.red == 0 && srgb.green == 0 && srgb.blue == 0 {
			self.init(0, 0, 0)
			return
		}

		let lab = OkLab(srgb: srgb)
		let c = sqrt(lab.a * lab.a + lab.b * lab.b)
		guard c > 1e-10 else {
			self.init(0, 0, OkColorModuleToe(lab.l))
			return
		}

		let a_ = lab.a / c
		let b_ = lab.b / c
		var lightness = lab.l
		var chroma = c
		let h = 0.5 + 0.5 * atan2(-lab.b, -lab.a) / .pi

		let cusp = okFindCusp(a_, b_)
		let stMax = cusp.st
		let s0 = 0.5
		let k = 1 - s0 / stMax.s

		let t = stMax.t / (chroma + lightness * stMax.t)
		let lV = t * lightness
		let cV = t * chroma
		let lVt = OkColorModuleToeInv(lV)
		let cVt = cV * lVt / lV
		let rgbScale = OkLab(lVt, a_ * cVt, b_ * cVt).linearSRGB
		let scaleL = pow(1 / max(max(rgbScale.red, rgbScale.green), max(rgbScale.blue, 1e-10)), 1.0 / 3.0)

		lightness /= scaleL
		chroma /= scaleL
		chroma = chroma * OkColorModuleToe(lightness) / lightness
		lightness = OkColorModuleToe(lightness)

		let v = lightness / lV
		let s = (s0 + stMax.t) * cV / (stMax.t * s0 + stMax.t * k * cV)

		if srgb.red == srgb.green && srgb.green == srgb.blue {
			self.init(0, 0, v)
		} else {
			self.init(okPositiveModulo(h, 1), s, v)
		}
	}

	var srgb: SRGB {
		if v == 0 {
			return SRGB(0, 0, 0)
		}

		let a_ = cos(2 * .pi * h)
		let b_ = sin(2 * .pi * h)
		let cusp = okFindCusp(a_, b_)
		let stMax = cusp.st
		let s0 = 0.5
		let k = 1 - s0 / stMax.s

		let lV = 1 - s * s0 / (s0 + stMax.t - stMax.t * k * s)
		let cV = s * stMax.t * s0 / (s0 + stMax.t - stMax.t * k * s)
		let lVt = OkColorModuleToeInv(lV)
		let cVt = cV * lVt / lV
		var lightness = v * lV
		var chroma = v * cV

		let lNew = OkColorModuleToeInv(lightness)
		chroma = chroma * lNew / max(lightness, 1e-10)
		lightness = lNew

		let rgbScale = OkLab(lVt, a_ * cVt, b_ * cVt).linearSRGB
		let scaleL = pow(1 / max(max(rgbScale.red, rgbScale.green), max(rgbScale.blue, 1e-10)), 1.0 / 3.0)

		lightness *= scaleL
		chroma *= scaleL

		return OkLab(lightness, chroma * a_, chroma * b_).srgb
	}

	func withHue(_ h: Double) -> OkHsv {
		OkHsv(h, s, v)
	}

	func withSaturation(_ s: Double) -> OkHsv {
		OkHsv(h, s, v)
	}

	func withValue(_ v: Double) -> OkHsv {
		OkHsv(h, s, v)
	}

	func darker(_ percentage: Double) -> OkHsv {
		withValue(okLerp(v, 0, percentage))
	}

	func lighter(_ percentage: Double) -> OkHsv {
		withValue(okLerp(v, 1, percentage))
	}

	func saturate(_ percentage: Double) -> OkHsv {
		withSaturation(okLerp(s, 1, percentage))
	}

	func desaturate(_ percentage: Double) -> OkHsv {
		withSaturation(okLerp(s, 0, percentage))
	}

	func rotated(_ degrees: Double) -> OkHsv {
		withHue(okPositiveModulo(h + degrees / 360, 1))
	}

	func complementary() -> OkHsv {
		rotated(180)
	}

	func splitComplementary() -> [OkHsv] {
		[rotated(150), self, rotated(210)]
	}

	func triadic() -> [OkHsv] {
		[rotated(120), self, rotated(240)]
	}

	func tetradic() -> [OkHsv] {
		[self, complementary(), rotated(90), rotated(270)]
	}

	func analogous(count: Int = 2, angle: Double = 30) -> [OkHsv] {
		guard count > 0 else {
			return [self]
		}
		return (1 ... count).reversed().map { rotated(angle * Double($0)) } + [self] + (1 ... count).map { rotated(-angle * Double($0)) }
	}

	func shades(count: Int = 5) -> [OkHsv] {
		guard count > 1 else {
			return count == 1 ? [self] : []
		}
		return (0 ..< count).map { darker(Double($0) / Double(count - 1)) }
	}

	func tints(count: Int = 5) -> [OkHsv] {
		guard count > 1 else {
			return count == 1 ? [self] : []
		}
		return (0 ..< count).map { lighter(Double($0) / Double(count - 1)) }
	}

	func lerp(to other: OkHsv, t: Double, shortestPath: Bool = true) -> OkHsv {
		OkHsv(
			lerpAngle(h, other.h, t, shortestPath: shortestPath),
			okLerp(s, other.s, t),
			okLerp(v, other.v, t)
		)
	}
}
