# Gradient Routes

Compare traditional HSL interpolation with Oklab and OkLch hue routes.

## Overview

The following generated comparisons use saturated endpoint pairs to make hue-route behavior visible. Each image shows four color rows followed by the same four rows in grayscale. The row order is HSL, straight Oklab, OkLch shortest path, and OkLch long path.

Straight Oklab interpolation is often smoother than HSL, but colors on opposite sides of the hue wheel can pass through low-chroma gray. For those endpoint pairs, a polar hue interpolation method such as ``OkColorInterpolationMethod/oklch`` can preserve a more colorful route. Use `shortestPath` to choose whether the hue travels the short or long way around the wheel.

## Blue to Yellow

![Blue to yellow HSL, Oklab, and OkLch gradient comparison](okcolor-methods-blue-yellow.png)

## Red to Cyan

![Red to cyan HSL, Oklab, and OkLch gradient comparison](okcolor-methods-red-cyan.png)

## Purple to Gold

![Purple to gold HSL, Oklab, and OkLch gradient comparison](okcolor-methods-purple-gold.png)

## Magenta to Green

![Magenta to green HSL, Oklab, and OkLch gradient comparison](okcolor-methods-magenta-green.png)

## Generate the Assets

The comparison images are generated from package sources, so they can be refreshed when interpolation behavior changes.

```bash
python3 Scripts/generate_gradient_comparisons.py
```
