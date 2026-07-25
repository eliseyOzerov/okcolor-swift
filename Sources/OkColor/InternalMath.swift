import Foundation

func srgbToLinear(_ c: Double) -> Double {
	c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
}

func linearToSrgb(_ c: Double, clamping: Bool) -> Double {
	let value = clamping ? min(max(c, 0), 1) : c
	return value <= 0.0031308 ? 12.92 * value : 1.055 * pow(value, 1.0 / 2.4) - 0.055
}

func okCbrt(_ x: Double) -> Double {
	x >= 0 ? pow(x, 1.0 / 3.0) : -pow(-x, 1.0 / 3.0)
}

func okLerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
	a + (b - a) * t
}

func lerpAngle(_ start: Double, _ end: Double, _ t: Double, range: Double = 1, shortestPath: Bool = true) -> Double {
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

func okPositiveModulo(_ x: Double, _ range: Double) -> Double {
	let remainder = x.truncatingRemainder(dividingBy: range)
	return remainder < 0 ? remainder + range : remainder
}

// Mirrors ok_color::toe.
func OkColorModuleToe(_ x: Double) -> Double {
	let k1 = 0.206
	let k2 = 0.03
	let k3 = (1 + k1) / (1 + k2)
	return 0.5 * (k3 * x - k1 + sqrt((k3 * x - k1) * (k3 * x - k1) + 4 * k2 * k3 * x))
}

// Mirrors ok_color::toe_inv.
func OkColorModuleToeInv(_ x: Double) -> Double {
	let k1 = 0.206
	let k2 = 0.03
	let k3 = (1 + k1) / (1 + k2)
	return (x * x + k1 * x) / (k3 * (x + k2))
}

// Mirrors ok_color::compute_max_saturation.
func okComputeMaxSaturation(_ a: Double, _ b: Double) -> Double {
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

// Mirrors ok_color::find_cusp.
func okFindCusp(_ a: Double, _ b: Double) -> LCCusp {
	let sCusp = okComputeMaxSaturation(a, b)
	let rgbAtMax = OkLab(1, sCusp * a, sCusp * b).linearSRGB
	let lCusp = pow(1 / max(max(rgbAtMax.red, rgbAtMax.green), rgbAtMax.blue), 1.0 / 3.0)
	return LCCusp(lCusp, lCusp * sCusp)
}

// Mirrors ok_color::find_gamut_intersection.
func okFindGamutIntersection(_ a: Double, _ b: Double, _ l1: Double, _ c1: Double, _ l0: Double, _ cusp: LCCusp) -> Double {
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

// Mirrors ok_color::get_ST_mid.
func getSTMid(_ a: Double, _ b: Double) -> STPair {
	let s = 0.11516993 +
		1 / (7.44778970 + 4.15901240 * b + a * (-2.19557347 + 1.75198401 * b + a * (-2.13704948 - 10.02301043 * b + a * (-4.24894561 + 5.38770819 * b + 4.69891013 * a))))

	let t = 0.11239642 +
		1 / (1.61320320 - 0.68124379 * b + a * (0.40370612 + 0.90148123 * b + a * (-0.27087943 + 0.61223990 * b + a * (0.00299215 - 0.45399568 * b - 0.14661872 * a))))

	return STPair(s, t)
}

// Mirrors ok_color::get_Cs.
func getCs(_ l: Double, _ a: Double, _ b: Double) -> ChromaSet {
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

extension OkHue {
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

extension Double {
	var degreesToRadians: Double {
		self * .pi / 180
	}
}
