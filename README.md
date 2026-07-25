# OkColor

OkColor is a small Swift package for working with the Oklab and OkLch color
spaces. It provides value types for Oklab, OkLch, linear sRGB, and gamma-encoded
sRGB, plus conversions and interpolation helpers.

## Origin

Oklab was designed by [Björn Ottosson](https://bottosson.github.io/). The color
space was introduced in his research article
[A perceptual color space for image processing](https://bottosson.github.io/posts/oklab/),
published in 2020.

This package implements the sRGB/Oklab conversion path from Ottosson's reference
work in Swift.

## Premise

RGB is convenient for displays, but it is not perceptually uniform: equal numeric
changes in RGB do not usually look like equal visual changes. Oklab is designed
for image and UI color work where perceived lightness, chroma, and hue should be
more predictable.

Use Oklab when you want smoother gradients, perceptual interpolation, or color
adjustments that better preserve perceived hue and lightness. Use OkLch when the
same space is easier to work with as lightness, chroma, and hue.

## Installation

Add the package to a Swift package manifest:

```swift
.package(name: "OkColor", url: "https://github.com/eliseyOzerov/okcolor-swift", branch: "main")
```

Then depend on the library product:

```swift
.product(name: "OkColor", package: "OkColor")
```

Import it where needed:

```swift
import OkColor
```

## Public API

### `SRGB`

Gamma-encoded sRGB channels, typically in the `0...1` range.

```swift
public struct SRGB: Equatable, Hashable, Sendable {
	public var red: Double
	public var green: Double
	public var blue: Double

	public init(_ red: Double, _ green: Double, _ blue: Double)
	public var linear: LinearSRGB
}
```

### `LinearSRGB`

Linear sRGB channels used by the Oklab conversion matrices.

```swift
public struct LinearSRGB: Equatable, Hashable, Sendable {
	public var red: Double
	public var green: Double
	public var blue: Double

	public init(_ red: Double, _ green: Double, _ blue: Double)
	public var srgb: SRGB
}
```

`LinearSRGB.srgb` clamps each channel into the displayable sRGB gamut before
gamma encoding.

### `OkLab`

Perceptually uniform Lab-style coordinates:

- `l`: perceived lightness
- `a`: green-red opponent axis
- `b`: blue-yellow opponent axis

```swift
public struct OkLab: Equatable, Hashable, Sendable {
	public var l: Double
	public var a: Double
	public var b: Double

	public init(_ l: Double, _ a: Double, _ b: Double)
	public init(srgb: SRGB)
	public init(linearSRGB rgb: LinearSRGB)

	public var srgb: SRGB
	public var linearSRGB: LinearSRGB

	public func lerp(to other: OkLab, t: Double) -> OkLab
}
```

### `OkLch`

Cylindrical Oklab coordinates:

- `l`: perceived lightness
- `c`: chroma
- `h`: hue angle in radians

```swift
public struct OkLch: Equatable, Hashable, Sendable {
	public var l: Double
	public var c: Double
	public var h: Double

	public init(_ l: Double, _ c: Double, _ h: Double)
	public init(oklab lab: OkLab)
	public init(srgb: SRGB)

	public var oklab: OkLab
	public var srgb: SRGB

	public func lerp(to other: OkLch, t: Double) -> OkLch
}
```

`OkLch.lerp(to:t:)` interpolates hue along the shortest angular path.

## Examples

Convert sRGB to Oklab and back:

```swift
let red = SRGB(1, 0, 0)
let lab = OkLab(srgb: red)
let rgb = lab.srgb
```

Interpolate two colors perceptually:

```swift
let start = OkLab(srgb: SRGB(0.2, 0.4, 1.0))
let end = OkLab(srgb: SRGB(1.0, 0.4, 0.2))
let middle = start.lerp(to: end, t: 0.5).srgb
```

Adjust chroma in OkLch:

```swift
var color = OkLch(srgb: SRGB(0.4, 0.7, 0.9))
color.c *= 1.2
let saturated = color.srgb
```
