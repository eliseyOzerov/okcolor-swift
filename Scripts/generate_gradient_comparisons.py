#!/usr/bin/env python3
"""Generate README gradient comparison images.

The generated PNGs compare classic HSL interpolation, straight Oklab
interpolation, and Oklch hue-route interpolation. The Oklab constants match
Sources/OkColor/OkLab.swift.
"""

from __future__ import annotations

import math
import os
import struct
import zlib

WIDTH = 960
STRIP_HEIGHT = 46
ROW_GAP = 4
SECTION_GAP = 10
BACKGROUND = (246, 246, 243)
VARIATIONS = [
	('blue-yellow', (0.00, 0.00, 1.00), (1.00, 1.00, 0.00)),
	('red-cyan', (1.00, 0.00, 0.00), (0.00, 1.00, 1.00)),
	('purple-gold', (0.65, 0.00, 1.00), (0.95, 0.78, 0.00)),
	('magenta-green', (0.92, 0.02, 0.74), (0.04, 0.88, 0.35)),
]


def clamp(value: float, lower: float = 0.0, upper: float = 1.0) -> float:
	return min(max(value, lower), upper)


def lerp(a: float, b: float, t: float) -> float:
	return a + (b - a) * t


def srgb_to_linear(c: float) -> float:
	return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def linear_to_srgb(c: float) -> float:
	c = clamp(c)
	return 12.92 * c if c <= 0.0031308 else 1.055 * (c ** (1.0 / 2.4)) - 0.055


def cbrt(value: float) -> float:
	return math.copysign(abs(value) ** (1.0 / 3.0), value)


def srgb_to_oklab(rgb: tuple[float, float, float]) -> tuple[float, float, float]:
	r, g, b = (srgb_to_linear(channel) for channel in rgb)
	l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
	m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
	s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
	l_, m_, s_ = cbrt(l), cbrt(m), cbrt(s)
	return (
		0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
		1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
		0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_,
	)


def oklab_to_srgb(lab: tuple[float, float, float]) -> tuple[float, float, float]:
	l, a, b = lab
	l_ = l + 0.3963377774 * a + 0.2158037573 * b
	m_ = l - 0.1055613458 * a - 0.0638541728 * b
	s_ = l - 0.0894841775 * a - 1.2914855480 * b
	l3, m3, s3 = l_ * l_ * l_, m_ * m_ * m_, s_ * s_ * s_
	return (
		linear_to_srgb(4.0767416621 * l3 - 3.3077115913 * m3 + 0.2309699292 * s3),
		linear_to_srgb(-1.2684380046 * l3 + 2.6097574011 * m3 - 0.3413193965 * s3),
		linear_to_srgb(-0.0041960863 * l3 - 0.7034186147 * m3 + 1.7076147010 * s3),
	)


def srgb_to_oklch(rgb: tuple[float, float, float]) -> tuple[float, float, float]:
	l, a, b = srgb_to_oklab(rgb)
	return (l, math.sqrt(a * a + b * b), math.atan2(b, a))


def oklch_to_srgb(lch: tuple[float, float, float]) -> tuple[float, float, float]:
	l, c, h = lch
	return oklab_to_srgb((l, c * math.cos(h), c * math.sin(h)))


def rgb_to_hsl(rgb: tuple[float, float, float]) -> tuple[float, float, float]:
	r, g, b = rgb
	max_c = max(rgb)
	min_c = min(rgb)
	lightness = (max_c + min_c) / 2
	if max_c == min_c:
		return (0.0, 0.0, lightness)

	delta = max_c - min_c
	saturation = delta / (2 - max_c - min_c) if lightness > 0.5 else delta / (max_c + min_c)
	if max_c == r:
		hue = ((g - b) / delta + (6 if g < b else 0)) / 6
	elif max_c == g:
		hue = ((b - r) / delta + 2) / 6
	else:
		hue = ((r - g) / delta + 4) / 6
	return (hue, saturation, lightness)


def hue_to_rgb(p: float, q: float, t: float) -> float:
	if t < 0:
		t += 1
	if t > 1:
		t -= 1
	if t < 1 / 6:
		return p + (q - p) * 6 * t
	if t < 1 / 2:
		return q
	if t < 2 / 3:
		return p + (q - p) * (2 / 3 - t) * 6
	return p


def hsl_to_rgb(hsl: tuple[float, float, float]) -> tuple[float, float, float]:
	hue, saturation, lightness = hsl
	if saturation == 0:
		return (lightness, lightness, lightness)
	q = lightness * (1 + saturation) if lightness < 0.5 else lightness + saturation - lightness * saturation
	p = 2 * lightness - q
	return (
		hue_to_rgb(p, q, hue + 1 / 3),
		hue_to_rgb(p, q, hue),
		hue_to_rgb(p, q, hue - 1 / 3),
	)


def positive_modulo(value: float, range_: float) -> float:
	result = value % range_
	return result + range_ if result < 0 else result


def lerp_angle(start: float, end: float, t: float, range_: float, shortest_path: bool) -> float:
	delta_a = abs(end - start)
	delta_b = range_ - delta_a
	shortest_crosses_range = shortest_path and delta_b < delta_a and delta_b != 0
	longer_crosses_range = not shortest_path and delta_b > delta_a and start != end

	if shortest_crosses_range or longer_crosses_range:
		if end > start:
			return positive_modulo(lerp(start + range_, end, t), range_)
		return positive_modulo(lerp(start, end + range_, t), range_)
	return positive_modulo(lerp(start, end, t), range_)


def interpolate_hsl(start: tuple[float, float, float], end: tuple[float, float, float], t: float) -> tuple[float, float, float]:
	start_h, start_s, start_l = rgb_to_hsl(start)
	end_h, end_s, end_l = rgb_to_hsl(end)
	hue = lerp_angle(start_h, end_h, t, 1.0, True)
	return hsl_to_rgb((hue, lerp(start_s, end_s, t), lerp(start_l, end_l, t)))


def interpolate_oklab(start: tuple[float, float, float], end: tuple[float, float, float], t: float) -> tuple[float, float, float]:
	start_lab = srgb_to_oklab(start)
	end_lab = srgb_to_oklab(end)
	return oklab_to_srgb(tuple(lerp(start_lab[index], end_lab[index], t) for index in range(3)))


def interpolate_oklch(start: tuple[float, float, float], end: tuple[float, float, float], t: float, shortest_path: bool) -> tuple[float, float, float]:
	start_l, start_c, start_h = srgb_to_oklch(start)
	end_l, end_c, end_h = srgb_to_oklch(end)
	return oklch_to_srgb((
		lerp(start_l, end_l, t),
		lerp(start_c, end_c, t),
		lerp_angle(start_h, end_h, t, 2 * math.pi, shortest_path),
	))


def interpolate_oklch_short(start: tuple[float, float, float], end: tuple[float, float, float], t: float) -> tuple[float, float, float]:
	return interpolate_oklch(start, end, t, True)


def interpolate_oklch_long(start: tuple[float, float, float], end: tuple[float, float, float], t: float) -> tuple[float, float, float]:
	return interpolate_oklch(start, end, t, False)


def oklab_grayscale(rgb: tuple[float, float, float]) -> tuple[float, float, float]:
	lightness = srgb_to_oklab(rgb)[0]
	return oklab_to_srgb((lightness, 0.0, 0.0))


def to_byte(channel: float) -> int:
	return int(round(clamp(channel) * 255))


def make_method_comparison_image(start: tuple[float, float, float], end: tuple[float, float, float]) -> tuple[int, int, list[tuple[int, int, int]]]:
	methods = (interpolate_hsl, interpolate_oklab, interpolate_oklch_short, interpolate_oklch_long)
	row_count = len(methods) * 2
	height = row_count * STRIP_HEIGHT + (row_count - 2) * ROW_GAP + SECTION_GAP
	pixels = [BACKGROUND] * (WIDTH * height)

	rows = [(method, False) for method in methods] + [(method, True) for method in methods]
	for row_index, (interpolator, grayscale) in enumerate(rows):
		row_y = row_index * (STRIP_HEIGHT + ROW_GAP)
		if row_index >= len(methods):
			row_y += SECTION_GAP - ROW_GAP
		for x in range(WIDTH):
			t = x / (WIDTH - 1)
			rgb = interpolator(start, end, t)
			if grayscale:
				rgb = oklab_grayscale(rgb)
			pixel = tuple(to_byte(channel) for channel in rgb)
			for dy in range(STRIP_HEIGHT):
				pixels[(row_y + dy) * WIDTH + x] = pixel

	return WIDTH, height, pixels

def png_chunk(chunk_type: bytes, data: bytes) -> bytes:
	return struct.pack('>I', len(data)) + chunk_type + data + struct.pack('>I', zlib.crc32(chunk_type + data) & 0xFFFFFFFF)


def write_png(path: str, width: int, height: int, pixels: list[tuple[int, int, int]]) -> None:
	raw_rows = []
	for y in range(height):
		row = bytearray([0])
		for x in range(width):
			row.extend(pixels[y * width + x])
		raw_rows.append(bytes(row))
	raw = b''.join(raw_rows)
	png = b'\x89PNG\r\n\x1a\n'
	png += png_chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0))
	png += png_chunk(b'IDAT', zlib.compress(raw, 9))
	png += png_chunk(b'IEND', b'')
	with open(path, 'wb') as file:
		file.write(png)


def main() -> None:
	root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
	output_dir = os.path.join(root, 'Docs', 'Images')
	os.makedirs(output_dir, exist_ok=True)
	for name, start, end in VARIATIONS:
		width, height, pixels = make_method_comparison_image(start, end)
		write_png(os.path.join(output_dir, f'okcolor-methods-{name}.png'), width, height, pixels)


if __name__ == '__main__':
	main()
