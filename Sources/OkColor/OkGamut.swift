import Foundation

/// Maximum saturation and gamut helpers used by OkHSL and OkHSV conversion.
public enum OkGamut {
	/// Computes the maximum saturation for a normalized Oklab hue direction.
	public static func computeMaxSaturation(_ a: Double, _ b: Double) -> Double {
		okComputeMaxSaturation(a, b)
	}

	/// Finds the lightness and chroma cusp for a normalized Oklab hue direction.
	public static func findCusp(_ a: Double, _ b: Double) -> (l: Double, c: Double) {
		let cusp = okFindCusp(a, b)
		return (cusp.l, cusp.c)
	}

	/// Finds where a line from `(l0, 0)` toward `(l1, c1)` intersects the sRGB gamut boundary.
	public static func findGamutIntersection(_ a: Double, _ b: Double, l1: Double, c1: Double, l0: Double, cusp: (l: Double, c: Double)) -> Double {
		okFindGamutIntersection(a, b, l1, c1, l0, LCCusp(cusp.l, cusp.c))
	}

	/// Applies Ottosson's toe curve to an Oklab lightness value.
	public static func toe(_ x: Double) -> Double {
		OkColorModuleToe(x)
	}

	/// Applies the inverse of Ottosson's toe curve to a lightness value.
	public static func toeInverse(_ x: Double) -> Double {
		OkColorModuleToeInv(x)
	}
}
