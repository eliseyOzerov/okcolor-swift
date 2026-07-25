import Foundation

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
