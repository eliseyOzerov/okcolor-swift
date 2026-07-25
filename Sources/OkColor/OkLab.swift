import Foundation

public extension OkLab {
	/// Creates an OkLab value from gamma-encoded sRGB channels.
	init(srgb: SRGB) {
		self.init(linearSRGB: srgb.linear)
	}

	/// Creates an OkLab value from linear sRGB channels.
	///
	/// Mirrors `ok_color::linear_srgb_to_oklab`.
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
	///
	/// Mirrors `ok_color::oklab_to_linear_srgb`.
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
