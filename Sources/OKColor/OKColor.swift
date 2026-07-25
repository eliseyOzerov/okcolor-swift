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

public extension OkLab {
	/// Creates an OkLab value from gamma-encoded sRGB channels.
	init(srgb: SRGB) {
		self.init(linearSRGB: srgb.linear)
	}

	/// Creates an OkLab value from linear sRGB channels.
	init(linearSRGB rgb: LinearSRGB) {
		let r = rgb.red
		let g = rgb.green
		let b = rgb.blue

		let l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
		let m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
		let s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

		let l_ = okCbrt(l)
		let m_ = okCbrt(m)
		let s_ = okCbrt(s)

		self.init(
			0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
			1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
			0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
		)
	}

	/// Converts this OkLab value to gamma-encoded sRGB channels.
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

	/// Linearly interpolates to another OkLab value.
	func lerp(to other: OkLab, t: Double) -> OkLab {
		OkLab(
			l + (other.l - l) * t,
			a + (other.a - a) * t,
			b + (other.b - b) * t
		)
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

	/// Converts this OkLch value to gamma-encoded sRGB channels.
	var srgb: SRGB {
		oklab.srgb
	}

	/// Linearly interpolates to another OkLch value using shortest-path hue interpolation.
	func lerp(to other: OkLch, t: Double) -> OkLch {
		OkLch(
			l + (other.l - l) * t,
			c + (other.c - c) * t,
			lerpAngle(h, other.h, t)
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
}

public extension LinearSRGB {
	/// Converts linear sRGB channels to gamma-encoded sRGB channels, clamping each channel into sRGB gamut.
	var srgb: SRGB {
		SRGB(
			linearToSrgb(red),
			linearToSrgb(green),
			linearToSrgb(blue)
		)
	}
}

private func srgbToLinear(_ c: Double) -> Double {
	c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
}

private func linearToSrgb(_ c: Double) -> Double {
	let clamped = min(max(c, 0), 1)
	return clamped <= 0.0031308 ? 12.92 * clamped : 1.055 * pow(clamped, 1.0 / 2.4) - 0.055
}

private func okCbrt(_ x: Double) -> Double {
	x >= 0 ? pow(x, 1.0 / 3.0) : -pow(-x, 1.0 / 3.0)
}

private func lerpAngle(_ a: Double, _ b: Double, _ t: Double) -> Double {
	var diff = b - a
	while diff > .pi { diff -= 2 * .pi }
	while diff < -.pi { diff += 2 * .pi }
	return a + diff * t
}
