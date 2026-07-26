# Choosing Interpolation Methods

Pick an interpolation method based on whether you want straight perceptual mixing, polar hue routing, color-picker behavior, or raw channel interpolation.

## Overview

``OkColor/interpolate(_:_:t:method:shortestPath:)`` and ``OkColor/gradient(from:to:count:method:shortestPath:)`` accept an ``OkColorInterpolationMethod``. The default, ``OkColorInterpolationMethod/oklab``, interpolates directly through Oklab and is often a strong general-purpose choice.

```swift
let start = SRGB(0.0, 0.25, 1.0)
let end = SRGB(1.0, 0.85, 0.0)

let middle = OkColor.interpolate(start, end, t: 0.5, method: .oklab)
let ramp = OkColor.gradient(from: start, to: end, count: 12, method: .oklch)
```

Use ``OkColorInterpolationMethod/oklch`` when you want to interpolate lightness, chroma, and hue in polar Oklab coordinates. This avoids some low-chroma gray centers that can appear when saturated colors are mixed directly through Oklab.

```swift
let shortRoute = OkColor.gradient(
	from: start,
	to: end,
	count: 12,
	method: .oklch,
	shortestPath: true
)

let longRoute = OkColor.gradient(
	from: start,
	to: end,
	count: 12,
	method: .oklch,
	shortestPath: false
)
```

Use ``OkColorInterpolationMethod/okhsl`` or ``OkColorInterpolationMethod/okhsv`` when you want hue-wheel behavior similar to HSL or HSV controls, but with the improved perceptual model from Oklab. Use ``OkColorInterpolationMethod/hsv`` for traditional HSV interpolation, and ``OkColorInterpolationMethod/rgb`` when direct sRGB channel interpolation is the desired behavior.

## Hue Routes

For hue-based methods, `shortestPath` chooses how angles move around the hue wheel. `true` takes the shorter path. `false` takes the longer route, which can produce a more colorful transition for endpoint pairs that would otherwise cross a dull center.

See <doc:GradientRoutes> for visual examples.
