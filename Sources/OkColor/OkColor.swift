import Foundation

/// Perceptually uniform color space. L is lightness, a is the green-red axis, and b is the blue-yellow axis.
public struct OkLab: Equatable, Hashable, Sendable {
	public var l: Double
	public var a: Double
	public var b: Double

	public init(_ l: Double, _ a: Double, _ b: Double) {
		self.l = l
		self.a = a
		self.b = b
	}
}

/// Perceptually uniform cylindrical color space. l is lightness, c is chroma, and h is hue in radians.
public struct OkLch: Equatable, Hashable, Sendable {
	public var l: Double
	public var c: Double
	public var h: Double

	public init(_ l: Double, _ c: Double, _ h: Double) {
		self.l = l
		self.c = c
		self.h = h
	}
}

/// Oklab-based hue, saturation, and lightness color space from Björn Ottosson's color picker work.
public struct OkHsl: Equatable, Hashable, Sendable {
	public var h: Double
	public var s: Double
	public var l: Double

	public init(_ h: Double, _ s: Double, _ l: Double) {
		self.h = h
		self.s = s
		self.l = l
	}
}

/// Oklab-based hue, saturation, and value color space from Björn Ottosson's color picker work.
public struct OkHsv: Equatable, Hashable, Sendable {
	public var h: Double
	public var s: Double
	public var v: Double

	public init(_ h: Double, _ s: Double, _ v: Double) {
		self.h = h
		self.s = s
		self.v = v
	}
}

/// Linear sRGB channel triplet used when converting through `OkLab` and `OkLch`.
public struct LinearSRGB: Equatable, Hashable, Sendable {
	public var red: Double
	public var green: Double
	public var blue: Double

	public init(_ red: Double, _ green: Double, _ blue: Double) {
		self.red = red
		self.green = green
		self.blue = blue
	}
}

/// Gamma-encoded sRGB channel triplet used when converting through `OkLab` and `OkLch`.
public struct SRGB: Equatable, Hashable, Sendable {
	public var red: Double
	public var green: Double
	public var blue: Double

	public init(_ red: Double, _ green: Double, _ blue: Double) {
		self.red = red
		self.green = green
		self.blue = blue
	}
}

/// CIE XYZ tristimulus coordinates used by Oklab conversion references.
public struct XYZ: Equatable, Hashable, Sendable {
	public var x: Double
	public var y: Double
	public var z: Double

	public init(_ x: Double, _ y: Double, _ z: Double) {
		self.x = x
		self.y = y
		self.z = z
	}
}

/// Oklab hue categories matching the Dart package's `Hue` enum.
public enum OkHue: CaseIterable, Hashable, Sendable {
	case red
	case orange
	case yellow
	case lime
	case green
	case teal
	case cyan
	case sky
	case blue
	case purple
	case magenta
	case pink
}

/// Interpolation strategies matching the Dart package's `InterpolationMethod` enum.
public enum OkColorInterpolationMethod: Hashable, Sendable {
	case oklab
	case okhsv
	case okhsl
	case oklch
	case hsv
	case rgb
}

/// Namespace for color interpolation and gradient helpers.
public enum OkColor {
	public static func interpolate(_ start: SRGB, _ end: SRGB, t: Double, method: OkColorInterpolationMethod = .oklab, shortestPath: Bool = true) -> SRGB {
		switch method {
		case .oklab:
			return OkLab(srgb: start).lerp(to: OkLab(srgb: end), t: t).srgb
		case .okhsv:
			return OkHsv(srgb: start).lerp(to: OkHsv(srgb: end), t: t, shortestPath: shortestPath).srgb
		case .okhsl:
			return OkHsl(srgb: start).lerp(to: OkHsl(srgb: end), t: t, shortestPath: shortestPath).srgb
		case .oklch:
			return OkLch(srgb: start).lerp(to: OkLch(srgb: end), t: t, shortestPath: shortestPath).srgb
		case .hsv:
			return HSV(srgb: start).lerp(to: HSV(srgb: end), t: t, shortestPath: shortestPath).srgb
		case .rgb:
			return start.lerp(to: end, t: t)
		}
	}

	public static func gradient(from start: SRGB, to end: SRGB, count: Int = 5, method: OkColorInterpolationMethod = .oklab, shortestPath: Bool = true) -> [SRGB] {
		guard count > 1 else {
			return count == 1 ? [start] : []
		}

		return (0 ..< count).map { index in
			let t = Double(index) / Double(count - 1)
			return interpolate(start, end, t: t, method: method, shortestPath: shortestPath)
		}
	}
}

public extension OkLab {
	/// Creates an OkLab value from gamma-encoded sRGB channels.
	init(srgb: SRGB) {
		self.init(linearSRGB: srgb.linear)
	}

	/// Creates an OkLab value from linear sRGB channels.
	init(linearSRGB rgb: LinearSRGB) {
		let l = 0.4122214708 * rgb.red + 0.5363325363 * rgb.green + 0.0514459929 * rgb.blue
		let m = 0.2119034982 * rgb.red + 0.6806995451 * rgb.green + 0.1073969566 * rgb.blue
		let s = 0.0883024619 * rgb.red + 0.2817188376 * rgb.green + 0.6299787005 * rgb.blue

		let l_ = okCbrt(l)
		let m_ = okCbrt(m)
		let s_ = okCbrt(s)

		self.init(
			0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
			1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
			0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
		)
	}

	/// Creates an OkLab value from CIE XYZ coordinates.
	init(xyz: XYZ) {
		let l = 0.8189330101 * xyz.x + 0.3618667424 * xyz.y - 0.1288597137 * xyz.z
		let m = 0.0329845436 * xyz.x + 0.9293118715 * xyz.y + 0.0361456387 * xyz.z
		let s = 0.0482003018 * xyz.x + 0.2643662691 * xyz.y + 0.6338517070 * xyz.z

		let l_ = okCbrt(l)
		let m_ = okCbrt(m)
		let s_ = okCbrt(s)

		self.init(
			0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
			1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
			0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
		)
	}

	/// Converts this OkLab value to gamma-encoded sRGB channels, clamped to the displayable sRGB gamut.
	var srgb: SRGB {
		linearSRGB.srgb
	}

	/// Converts this OkLab value to linear sRGB channels.
	var linearSRGB: LinearSRGB {
		let l_ = l + 0.3963377774 * a + 0.2158037573 * b
		let m_ = l - 0.1055613458 * a - 0.0638541728 * b
		let s_ = l - 0.0894841775 * a - 1.2914855480 * b

		let l = l_ * l_ * l_
		let m = m_ * m_ * m_
		let s = s_ * s_ * s_

		return LinearSRGB(
			4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
			-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
			-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
		)
	}

	/// Converts this OkLab value to CIE XYZ coordinates.
	var xyz: XYZ {
		let l_ = l + 0.3963377774 * a + 0.2158037573 * b
		let m_ = l - 0.1055613458 * a - 0.0638541728 * b
		let s_ = l - 0.0894841775 * a - 1.2914855480 * b

		let l = l_ * l_ * l_
		let m = m_ * m_ * m_
		let s = s_ * s_ * s_

		return XYZ(
			1.2270138511 * l - 0.5577999807 * m + 0.2812561490 * s,
			-0.0405801784 * l + 1.1122568696 * m - 0.0716766787 * s,
			-0.0763812845 * l - 0.4214819784 * m + 1.5861632204 * s
		)
	}

	var okLch: OkLch {
		OkLch(oklab: self)
	}

	var okHsl: OkHsl {
		OkHsl(srgb: srgb)
	}

	var okHsv: OkHsv {
		OkHsv(srgb: srgb)
	}

	func withLightness(_ l: Double) -> OkLab {
		OkLab(l, a, b)
	}

	func withA(_ a: Double) -> OkLab {
		OkLab(l, a, b)
	}

	func withB(_ b: Double) -> OkLab {
		OkLab(l, a, b)
	}

	func darker(_ percentage: Double) -> OkLab {
		OkLab(l * (1 - percentage), a, b)
	}

	func lighter(_ percentage: Double) -> OkLab {
		OkLab(l * (1 + percentage), a, b)
	}

	/// Linearly interpolates to another OkLab value.
	func lerp(to other: OkLab, t: Double) -> OkLab {
		OkLab(
			okLerp(l, other.l, t),
			okLerp(a, other.a, t),
			okLerp(b, other.b, t)
		)
	}

	static func + (lhs: OkLab, rhs: OkLab) -> OkLab {
		OkLab(lhs.l + rhs.l, lhs.a + rhs.a, lhs.b + rhs.b)
	}

	static func - (lhs: OkLab, rhs: OkLab) -> OkLab {
		OkLab(lhs.l - rhs.l, lhs.a - rhs.a, lhs.b - rhs.b)
	}
}

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

public extension LinearSRGB {
	/// Converts linear sRGB channels to gamma-encoded sRGB channels, clamping each channel into sRGB gamut.
	var srgb: SRGB {
		SRGB(
			linearToSrgb(red, clamping: true),
			linearToSrgb(green, clamping: true),
			linearToSrgb(blue, clamping: true)
		)
	}

	var unclampedSRGB: SRGB {
		SRGB(
			linearToSrgb(red, clamping: false),
			linearToSrgb(green, clamping: false),
			linearToSrgb(blue, clamping: false)
		)
	}

	var okLab: OkLab {
		OkLab(linearSRGB: self)
	}
}

public extension XYZ {
	init(linearSRGB rgb: LinearSRGB) {
		self.init(
			0.4124 * rgb.red + 0.3576 * rgb.green + 0.1805 * rgb.blue,
			0.2126 * rgb.red + 0.7152 * rgb.green + 0.0722 * rgb.blue,
			0.0193 * rgb.red + 0.1192 * rgb.green + 0.9505 * rgb.blue
		)
	}

	var linearSRGB: LinearSRGB {
		LinearSRGB(
			3.2406 * x - 1.5372 * y - 0.4986 * z,
			-0.9689 * x + 1.8758 * y + 0.0415 * z,
			0.0557 * x - 0.2040 * y + 1.0570 * z
		)
	}

	var okLab: OkLab {
		OkLab(xyz: self)
	}
}

/// Maximum saturation and gamut helpers used by OkHSL and OkHSV conversion.
public enum OkGamut {
	public static func computeMaxSaturation(_ a: Double, _ b: Double) -> Double {
		okComputeMaxSaturation(a, b)
	}

	public static func findCusp(_ a: Double, _ b: Double) -> (l: Double, c: Double) {
		let cusp = okFindCusp(a, b)
		return (cusp.l, cusp.c)
	}

	public static func findGamutIntersection(_ a: Double, _ b: Double, l1: Double, c1: Double, l0: Double, cusp: (l: Double, c: Double)) -> Double {
		okFindGamutIntersection(a, b, l1, c1, l0, LCCusp(cusp.l, cusp.c))
	}

	public static func toe(_ x: Double) -> Double {
		OkColorModuleToe(x)
	}

	public static func toeInverse(_ x: Double) -> Double {
		OkColorModuleToeInv(x)
	}
}

private struct LCCusp {
	var l: Double
	var c: Double

	init(_ l: Double, _ c: Double) {
		self.l = l
		self.c = c
	}

	var st: STPair {
		STPair(c / l, c / (1 - l))
	}
}

private struct STPair {
	var s: Double
	var t: Double

	init(_ s: Double, _ t: Double) {
		self.s = s
		self.t = t
	}
}

private struct ChromaSet {
	var c0: Double
	var cMid: Double
	var cMax: Double
}

private struct HSV {
	var h: Double
	var s: Double
	var v: Double

	init(srgb: SRGB) {
		let maxChannel = max(srgb.red, max(srgb.green, srgb.blue))
		let minChannel = min(srgb.red, min(srgb.green, srgb.blue))
		let delta = maxChannel - minChannel
		v = maxChannel
		s = maxChannel == 0 ? 0 : delta / maxChannel

		if delta == 0 {
			h = 0
		} else if maxChannel == srgb.red {
			h = okPositiveModulo((srgb.green - srgb.blue) / delta, 6) * 60
		} else if maxChannel == srgb.green {
			h = ((srgb.blue - srgb.red) / delta + 2) * 60
		} else {
			h = ((srgb.red - srgb.green) / delta + 4) * 60
		}
	}

	var srgb: SRGB {
		let c = v * s
		let x = c * (1 - abs(okPositiveModulo(h / 60, 2) - 1))
		let m = v - c
		let channels: (Double, Double, Double)

		switch h {
		case 0 ..< 60:
			channels = (c, x, 0)
		case 60 ..< 120:
			channels = (x, c, 0)
		case 120 ..< 180:
			channels = (0, c, x)
		case 180 ..< 240:
			channels = (0, x, c)
		case 240 ..< 300:
			channels = (x, 0, c)
		default:
			channels = (c, 0, x)
		}

		return SRGB(channels.0 + m, channels.1 + m, channels.2 + m)
	}

	func lerp(to other: HSV, t: Double, shortestPath: Bool) -> HSV {
		HSV(
			h: lerpAngle(h, other.h, t, range: 360, shortestPath: shortestPath),
			s: okLerp(s, other.s, t),
			v: okLerp(v, other.v, t)
		)
	}

	private init(h: Double, s: Double, v: Double) {
		self.h = h
		self.s = s
		self.v = v
	}
}

private func srgbToLinear(_ c: Double) -> Double {
	c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
}

private func linearToSrgb(_ c: Double, clamping: Bool) -> Double {
	let value = clamping ? min(max(c, 0), 1) : c
	return value <= 0.0031308 ? 12.92 * value : 1.055 * pow(value, 1.0 / 2.4) - 0.055
}

private func okCbrt(_ x: Double) -> Double {
	x >= 0 ? pow(x, 1.0 / 3.0) : -pow(-x, 1.0 / 3.0)
}

private func okLerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
	a + (b - a) * t
}

private func lerpAngle(_ start: Double, _ end: Double, _ t: Double, range: Double = 1, shortestPath: Bool = true) -> Double {
	let dA = abs(end - start)
	let dB = range - dA
	let shortestCrossesRange = shortestPath && dB < dA && dB != 0
	let longerCrossesRange = !shortestPath && dB > dA && start != end

	if shortestCrossesRange || longerCrossesRange {
		if end > start {
			return okPositiveModulo(okLerp(start + range, end, t), range)
		} else {
			return okPositiveModulo(okLerp(start, end + range, t), range)
		}
	}

	return okPositiveModulo(okLerp(start, end, t), range)
}

private func okPositiveModulo(_ x: Double, _ range: Double) -> Double {
	let remainder = x.truncatingRemainder(dividingBy: range)
	return remainder < 0 ? remainder + range : remainder
}

private func OkColorModuleToe(_ x: Double) -> Double {
	let k1 = 0.206
	let k2 = 0.03
	let k3 = (1 + k1) / (1 + k2)
	return 0.5 * (k3 * x - k1 + sqrt((k3 * x - k1) * (k3 * x - k1) + 4 * k2 * k3 * x))
}

private func OkColorModuleToeInv(_ x: Double) -> Double {
	let k1 = 0.206
	let k2 = 0.03
	let k3 = (1 + k1) / (1 + k2)
	return (x * x + k1 * x) / (k3 * (x + k2))
}

private func okComputeMaxSaturation(_ a: Double, _ b: Double) -> Double {
	let k0: Double
	let k1: Double
	let k2: Double
	let k3: Double
	let k4: Double
	let wl: Double
	let wm: Double
	let ws: Double

	if -1.88170328 * a - 0.80936493 * b > 1 {
		k0 = 1.19086277
		k1 = 1.76576728
		k2 = 0.59662641
		k3 = 0.75515197
		k4 = 0.56771245
		wl = 4.0767416621
		wm = -3.3077115913
		ws = 0.2309699292
	} else if 1.81444104 * a - 1.19445276 * b > 1 {
		k0 = 0.73956515
		k1 = -0.45954404
		k2 = 0.08285427
		k3 = 0.12541070
		k4 = 0.14503204
		wl = -1.2684380046
		wm = 2.6097574011
		ws = -0.3413193965
	} else {
		k0 = 1.35733652
		k1 = -0.00915799
		k2 = -1.15130210
		k3 = -0.50559606
		k4 = 0.00692167
		wl = -0.0041960863
		wm = -0.7034186147
		ws = 1.7076147010
	}

	var saturation = k0 + k1 * a + k2 * b + k3 * a * a + k4 * a * b
	let kL = 0.3963377774 * a + 0.2158037573 * b
	let kM = -0.1055613458 * a - 0.0638541728 * b
	let kS = -0.0894841775 * a - 1.2914855480 * b

	let l_ = 1 + saturation * kL
	let m_ = 1 + saturation * kM
	let s_ = 1 + saturation * kS

	let l = l_ * l_ * l_
	let m = m_ * m_ * m_
	let s = s_ * s_ * s_

	let lDS = 3 * kL * l_ * l_
	let mDS = 3 * kM * m_ * m_
	let sDS = 3 * kS * s_ * s_

	let lDS2 = 6 * kL * kL * l_
	let mDS2 = 6 * kM * kM * m_
	let sDS2 = 6 * kS * kS * s_

	let f = wl * l + wm * m + ws * s
	let f1 = wl * lDS + wm * mDS + ws * sDS
	let f2 = wl * lDS2 + wm * mDS2 + ws * sDS2

	saturation = saturation - f * f1 / (f1 * f1 - 0.5 * f * f2)
	return saturation
}

private func okFindCusp(_ a: Double, _ b: Double) -> LCCusp {
	let sCusp = okComputeMaxSaturation(a, b)
	let rgbAtMax = OkLab(1, sCusp * a, sCusp * b).linearSRGB
	let lCusp = pow(1 / max(max(rgbAtMax.red, rgbAtMax.green), rgbAtMax.blue), 1.0 / 3.0)
	return LCCusp(lCusp, lCusp * sCusp)
}

private func okFindGamutIntersection(_ a: Double, _ b: Double, _ l1: Double, _ c1: Double, _ l0: Double, _ cusp: LCCusp) -> Double {
	var t: Double

	if ((l1 - l0) * cusp.c - (cusp.l - l0) * c1) <= 0 {
		t = cusp.c * l0 / (c1 * cusp.l + cusp.c * (l0 - l1))
	} else {
		t = cusp.c * (l0 - 1) / (c1 * (cusp.l - 1) + cusp.c * (l0 - l1))
		let dL = l1 - l0
		let dC = c1
		let kL = 0.3963377774 * a + 0.2158037573 * b
		let kM = -0.1055613458 * a - 0.0638541728 * b
		let kS = -0.0894841775 * a - 1.2914855480 * b
		let lDt = dL + dC * kL
		let mDt = dL + dC * kM
		let sDt = dL + dC * kS

		let l = l0 * (1 - t) + t * l1
		let c = t * c1
		let l_ = l + c * kL
		let m_ = l + c * kM
		let s_ = l + c * kS

		let lCube = l_ * l_ * l_
		let mCube = m_ * m_ * m_
		let sCube = s_ * s_ * s_
		let ldt = 3 * lDt * l_ * l_
		let mdt = 3 * mDt * m_ * m_
		let sdt = 3 * sDt * s_ * s_
		let ldt2 = 6 * lDt * lDt * l_
		let mdt2 = 6 * mDt * mDt * m_
		let sdt2 = 6 * sDt * sDt * s_

		let r = 4.0767416621 * lCube - 3.3077115913 * mCube + 0.2309699292 * sCube - 1
		let r1 = 4.0767416621 * ldt - 3.3077115913 * mdt + 0.2309699292 * sdt
		let r2 = 4.0767416621 * ldt2 - 3.3077115913 * mdt2 + 0.2309699292 * sdt2
		let uR = r1 / (r1 * r1 - 0.5 * r * r2)
		var tR = -r * uR

		let g = -1.2684380046 * lCube + 2.6097574011 * mCube - 0.3413193965 * sCube - 1
		let g1 = -1.2684380046 * ldt + 2.6097574011 * mdt - 0.3413193965 * sdt
		let g2 = -1.2684380046 * ldt2 + 2.6097574011 * mdt2 - 0.3413193965 * sdt2
		let uG = g1 / (g1 * g1 - 0.5 * g * g2)
		var tG = -g * uG

		let blue = -0.0041960863 * lCube - 0.7034186147 * mCube + 1.7076147010 * sCube - 1
		let b1 = -0.0041960863 * ldt - 0.7034186147 * mdt + 1.7076147010 * sdt
		let b2 = -0.0041960863 * ldt2 - 0.7034186147 * mdt2 + 1.7076147010 * sdt2
		let uB = b1 / (b1 * b1 - 0.5 * blue * b2)
		var tB = -blue * uB

		tR = uR >= 0 ? tR : .infinity
		tG = uG >= 0 ? tG : .infinity
		tB = uB >= 0 ? tB : .infinity
		t += min(tR, min(tG, tB))
	}

	return t
}

private func getSTMid(_ a: Double, _ b: Double) -> STPair {
	let s = 0.11516993 +
		1 / (7.44778970 + 4.15901240 * b + a * (-2.19557347 + 1.75198401 * b + a * (-2.13704948 - 10.02301043 * b + a * (-4.24894561 + 5.38770819 * b + 4.69891013 * a))))

	let t = 0.11239642 +
		1 / (1.61320320 - 0.68124379 * b + a * (0.40370612 + 0.90148123 * b + a * (-0.27087943 + 0.61223990 * b + a * (0.00299215 - 0.45399568 * b - 0.14661872 * a))))

	return STPair(s, t)
}

private func getCs(_ l: Double, _ a: Double, _ b: Double) -> ChromaSet {
	let cusp = okFindCusp(a, b)
	let cMax = okFindGamutIntersection(a, b, l, 1, l, cusp)
	let stMax = cusp.st
	let k = cMax / min(l * stMax.s, (1 - l) * stMax.t)
	let stMid = getSTMid(a, b)
	let cA = l * stMid.s
	let cB = (1 - l) * stMid.t
	let cMid = 0.9 * k * sqrt(sqrt(1 / (1 / pow(cA, 4) + 1 / pow(cB, 4))))
	let c0A = l * 0.4
	let c0B = (1 - l) * 0.8
	let c0 = sqrt(1 / (1 / (c0A * c0A) + 1 / (c0B * c0B)))

	return ChromaSet(c0: c0, cMid: cMid, cMax: cMax)
}

private extension OkHue {
	static let hues: [OkHue: Double] = [
		.pink: 3,
		.red: 29,
		.orange: 53,
		.yellow: 110,
		.lime: 136,
		.green: 142,
		.teal: 151,
		.cyan: 195,
		.sky: 256,
		.blue: 264,
		.purple: 294,
		.magenta: 328,
	]
}

private extension Double {
	var degreesToRadians: Double {
		self * .pi / 180
	}
}
