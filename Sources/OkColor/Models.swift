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
