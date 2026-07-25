import Foundation

public extension XYZ {
	init(linearSRGB rgb: LinearSRGB) {
		self.init(
			0.4124 * rgb.red + 0.3576 * rgb.green + 0.1805 * rgb.blue,
			0.2126 * rgb.red + 0.7152 * rgb.green + 0.0722 * rgb.blue,
			0.0193 * rgb.red + 0.1192 * rgb.green + 0.9505 * rgb.blue
		)
	}

	var linearSRGB: LinearSRGB {
		LinearSRGB(
			3.2406 * x - 1.5372 * y - 0.4986 * z,
			-0.9689 * x + 1.8758 * y + 0.0415 * z,
			0.0557 * x - 0.2040 * y + 1.0570 * z
		)
	}

	var okLab: OkLab {
		OkLab(xyz: self)
	}
}
