import Foundation

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
