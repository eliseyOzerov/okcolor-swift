import Foundation

/// Gamut clipping strategies from Björn Ottosson's Oklab reference implementation.
public enum OkGamutClipping {
	/// Clips a linear sRGB color by preserving chroma as much as possible.
	///
	/// Mirrors `ok_color::gamut_clip_preserve_chroma`.
	public static func preserveChroma(_ rgb: LinearSRGB) -> LinearSRGB {
		guard !okIsInLinearSRGBGamut(rgb) else {
			return rgb
		}

		let lab = OkLab(linearSRGB: rgb)
		let clip = okGamutClipComponents(lab)
		let l0 = min(max(clip.lightness, 0), 1)
		return okGamutClip(clip, l0: l0)
	}

	/// Clips a linear sRGB color by projecting toward Oklab lightness 0.5.
	///
	/// Mirrors `ok_color::gamut_clip_project_to_0_5`.
	public static func projectToPointFive(_ rgb: LinearSRGB) -> LinearSRGB {
		guard !okIsInLinearSRGBGamut(rgb) else {
			return rgb
		}

		let lab = OkLab(linearSRGB: rgb)
		let clip = okGamutClipComponents(lab)
		return okGamutClip(clip, l0: 0.5)
	}

	/// Clips a linear sRGB color by projecting toward the cusp lightness for its hue.
	///
	/// Mirrors `ok_color::gamut_clip_project_to_L_cusp`.
	public static func projectToCusp(_ rgb: LinearSRGB) -> LinearSRGB {
		guard !okIsInLinearSRGBGamut(rgb) else {
			return rgb
		}

		let lab = OkLab(linearSRGB: rgb)
		let clip = okGamutClipComponents(lab)
		let cusp = okFindCusp(clip.a, clip.b)
		return okGamutClip(clip, l0: cusp.l, cusp: cusp)
	}

	/// Clips a linear sRGB color with the adaptive 0.5 lightness projection.
	///
	/// Mirrors `ok_color::gamut_clip_adaptive_L0_0_5`.
	public static func adaptivePointFive(_ rgb: LinearSRGB, alpha: Double = 0.05) -> LinearSRGB {
		guard !okIsInLinearSRGBGamut(rgb) else {
			return rgb
		}

		let lab = OkLab(linearSRGB: rgb)
		let clip = okGamutClipComponents(lab)
		let lightnessDelta = clip.lightness - 0.5
		let e1 = 0.5 + abs(lightnessDelta) + alpha * clip.chroma
		let l0 = 0.5 * (1 + okSign(lightnessDelta) * (e1 - sqrt(e1 * e1 - 2 * abs(lightnessDelta))))
		return okGamutClip(clip, l0: l0)
	}

	/// Clips a linear sRGB color with the adaptive cusp lightness projection.
	///
	/// Mirrors `ok_color::gamut_clip_adaptive_L0_L_cusp`.
	public static func adaptiveCusp(_ rgb: LinearSRGB, alpha: Double = 0.05) -> LinearSRGB {
		guard !okIsInLinearSRGBGamut(rgb) else {
			return rgb
		}

		let lab = OkLab(linearSRGB: rgb)
		let clip = okGamutClipComponents(lab)
		let cusp = okFindCusp(clip.a, clip.b)
		let lightnessDelta = clip.lightness - cusp.l
		let k = 2 * (lightnessDelta > 0 ? 1 - cusp.l : cusp.l)
		let e1 = 0.5 * k + abs(lightnessDelta) + alpha * clip.chroma / k
		let l0 = cusp.l + 0.5 * okSign(lightnessDelta) * (e1 - sqrt(e1 * e1 - 2 * k * abs(lightnessDelta)))
		return okGamutClip(clip, l0: l0, cusp: cusp)
	}
}

/// Normalized Oklab components used while applying a gamut clipping strategy.
private struct OkGamutClipComponents {
	var lightness: Double
	var chroma: Double
	var a: Double
	var b: Double
}

private func okIsInLinearSRGBGamut(_ rgb: LinearSRGB) -> Bool {
	rgb.red < 1 && rgb.green < 1 && rgb.blue < 1 && rgb.red > 0 && rgb.green > 0 && rgb.blue > 0
}

private func okGamutClipComponents(_ lab: OkLab) -> OkGamutClipComponents {
	let eps = 0.00001
	let chroma = max(eps, sqrt(lab.a * lab.a + lab.b * lab.b))
	return OkGamutClipComponents(
		lightness: lab.l,
		chroma: chroma,
		a: lab.a / chroma,
		b: lab.b / chroma
	)
}

private func okGamutClip(_ clip: OkGamutClipComponents, l0: Double, cusp: LCCusp? = nil) -> LinearSRGB {
	let t = okFindGamutIntersection(clip.a, clip.b, clip.lightness, clip.chroma, l0, cusp ?? okFindCusp(clip.a, clip.b))
	let clippedLightness = l0 * (1 - t) + t * clip.lightness
	let clippedChroma = t * clip.chroma
	return OkLab(clippedLightness, clippedChroma * clip.a, clippedChroma * clip.b).linearSRGB
}

private func okSign(_ value: Double) -> Double {
	(value > 0 ? 1 : 0) - (value < 0 ? 1 : 0)
}
