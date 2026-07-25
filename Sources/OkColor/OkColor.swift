import Foundation

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
