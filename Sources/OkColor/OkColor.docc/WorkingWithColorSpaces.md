# Working With Color Spaces

Convert between display sRGB, linear sRGB, Oklab, OkLch, OkHSL, OkHSV, and XYZ using plain Swift value types.

## Overview

Use ``SRGB`` for normal gamma-encoded display colors with channel values in the familiar `0...1` range. Convert to ``LinearSRGB`` before using APIs that explicitly operate on linear channels, and convert to ``OkLab`` or ``OkLch`` when you want perceptual lightness, chroma, and hue operations.

```swift
let display = SRGB(0.95, 0.25, 0.18)

let lab = display.okLab
let lch = display.okLch
let pickerColor = display.okHsl

let adjusted = lch
	.lighter(0.18)
	.saturate(0.12)
	.rotated(12)
	.srgb
```

``SRGB/linear`` converts gamma-encoded sRGB into linear sRGB. ``LinearSRGB/srgb`` clamps values into the displayable gamut before encoding back to sRGB. Use ``LinearSRGB/unclampedSRGB`` when you need exact transfer-function output for values that may be outside the displayable range.

```swift
let linear = LinearSRGB(1.2, 0.4, -0.1)
let displayable = linear.srgb
let referenceOutput = linear.unclampedSRGB
```

``OkLab`` is useful for straight perceptual interpolation. ``OkLch`` is useful when you want to reason about hue and chroma directly.

```swift
let base = SRGB(0.3, 0.55, 1.0).okLch
let palette = [
	base.srgb,
	base.complementary().srgb,
	base.rotated(30).srgb,
	base.desaturate(0.25).srgb,
]
```

## Channel Conventions

``OkLab`` stores lightness `l`, green-red axis `a`, and blue-yellow axis `b`. ``OkLch`` stores lightness `l`, chroma `c`, and hue `h` in radians. ``OkHsl`` and ``OkHsv`` store hue as a normalized `0...1` turn, matching the public Dart package that this Swift package mirrors.
