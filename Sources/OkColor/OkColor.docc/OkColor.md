# ``OkColor``

A Swift implementation of Bjorn Ottosson's Oklab, OkLch, OkHSL, OkHSV, and gamut helper math.

## Overview

OkColor gives Swift packages small value types for perceptual color work without taking a dependency on UIKit, AppKit, SwiftUI, or CoreGraphics. Use it when you need predictable color interpolation, Oklab-family conversions, hue-based palettes, or reference-compatible gamut clipping.

The package implements the color spaces and helpers from Bjorn Ottosson's Oklab research and color picker work. Oklab models colors so that numerical changes more closely match perceived visual changes than RGB or traditional HSL/HSV. OkLch exposes the same space as lightness, chroma, and hue, while OkHSL and OkHSV provide familiar color picker controls backed by Oklab math.

```swift
import OkColor

let blue = SRGB(0.1, 0.35, 1.0)
let yellow = SRGB(1.0, 0.84, 0.1)

let perceptual = OkColor.gradient(
	from: blue,
	to: yellow,
	count: 8,
	method: .oklch,
	shortestPath: true
)
```

## Topics

### Getting Started

- <doc:WorkingWithColorSpaces>
- <doc:ChoosingInterpolationMethods>
- <doc:GradientRoutes>
- <doc:GamutClipping>

### Color Models

- ``SRGB``
- ``LinearSRGB``
- ``XYZ``
- ``OkLab``
- ``OkLch``
- ``OkHsl``
- ``OkHsv``
- ``OkHue``

### Interpolation

- ``OkColor``
- ``OkColor/interpolate(_:_:t:method:shortestPath:)``
- ``OkColor/gradient(from:to:count:method:shortestPath:)``
- ``OkColorInterpolationMethod``

### Gamut Helpers

- ``OkGamut``
- ``OkGamutClipping``

### Reference and Attribution

- <doc:ReferenceParity>
- <doc:LicenseAndAttribution>
