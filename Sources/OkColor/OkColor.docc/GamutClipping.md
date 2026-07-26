# Gamut Clipping

Use OkColor's gamut helpers when Oklab operations produce linear sRGB values outside the displayable sRGB gamut.

## Overview

Oklab and OkLch make it easy to adjust lightness, chroma, and hue, but some adjusted colors cannot be represented by sRGB displays. ``OkGamutClipping`` provides the five clipping strategies from Ottosson's reference implementation.

Each clipping method accepts and returns ``LinearSRGB``. Convert back to display sRGB with ``LinearSRGB/srgb`` after clipping.

```swift
let boosted = SRGB(0.15, 0.45, 1.0)
	.okLch
	.saturate(0.5)
	.oklab
	.linearSRGB

let clipped = OkGamutClipping.adaptiveCusp(boosted).srgb
```

## Strategies

``OkGamutClipping/preserveChroma(_:)`` preserves chroma as much as possible while bringing a color back into gamut.

``OkGamutClipping/projectToPointFive(_:)`` projects toward Oklab lightness `0.5`.

``OkGamutClipping/projectToCusp(_:)`` projects toward the cusp lightness for the color's hue.

``OkGamutClipping/adaptivePointFive(_:alpha:)`` uses an adaptive projection around lightness `0.5`.

``OkGamutClipping/adaptiveCusp(_:alpha:)`` uses an adaptive projection around the hue cusp and is a good default when you want the reference implementation's perceptual gamut mapping behavior.

``OkGamut`` exposes lower-level reference helpers such as maximum saturation, cusp lookup, gamut intersection, and toe transfer functions for callers that need to build custom clipping behavior.
