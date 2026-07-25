import Foundation

/// Oklab lightness/chroma cusp used by gamut intersection and clipping helpers.
struct LCCusp {
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

/// Alternative cusp representation storing saturation and tangent limits.
struct STPair {
	var s: Double
	var t: Double

	init(_ s: Double, _ t: Double) {
		self.s = s
		self.t = t
	}
}

/// Chroma interpolation anchors used by OkHSL conversion.
struct ChromaSet {
	var c0: Double
	var cMid: Double
	var cMax: Double
}

/// RGB HSV helper used for non-Oklab interpolation.
struct HSV {
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
