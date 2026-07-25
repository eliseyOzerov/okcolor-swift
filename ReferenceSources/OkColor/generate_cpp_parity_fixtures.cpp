#include <cfloat>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

#include "oklab_source.h"

using namespace ok_color;

struct NamedRGB {
	const char* name;
	RGB rgb;
};

struct NamedLinearRGB {
	const char* name;
	RGB rgb;
};

static void print_array(RGB rgb) {
	std::cout << "[" << rgb.r << "," << rgb.g << "," << rgb.b << "]";
}

static void print_array(Lab lab) {
	std::cout << "[" << lab.L << "," << lab.a << "," << lab.b << "]";
}

static void print_array(Lch lch) {
	std::cout << "[" << lch.l << "," << lch.c << "," << lch.h << "]";
}

static void print_array(HSL hsl) {
	std::cout << "[" << hsl.h << "," << hsl.s << "," << hsl.l << "]";
}

static void print_array(HSV hsv) {
	std::cout << "[" << hsv.h << "," << hsv.s << "," << hsv.v << "]";
}

int main() {
	std::cout << std::fixed << std::setprecision(9);

	std::vector<NamedRGB> srgb_cases = {
		{"red", {1.0f, 0.0f, 0.0f}},
		{"green", {0.0f, 1.0f, 0.0f}},
		{"blue", {0.0f, 0.0f, 1.0f}},
		{"rose", {0.7f, 0.2f, 0.3f}},
		{"teal", {0.1f, 0.8f, 0.6f}},
		{"sky", {0.2f, 0.4f, 0.8f}},
		{"orange", {0.8f, 0.5f, 0.2f}},
		{"lavender", {0.6f, 0.4f, 0.7f}},
	};

	std::vector<NamedLinearRGB> clipping_cases = {
		{"in_gamut", {0.2f, 0.4f, 0.6f}},
		{"negative_red", {-0.2f, 0.5f, 0.4f}},
		{"high_green", {0.2f, 1.4f, 0.1f}},
		{"high_blue", {0.1f, 0.2f, 1.6f}},
		{"mixed", {1.2f, -0.1f, 0.8f}},
	};

	std::cout << "{\n  \"srgbCases\": [\n";
	for (size_t index = 0; index < srgb_cases.size(); ++index) {
		NamedRGB named = srgb_cases[index];
		RGB linear = {
			srgb_transfer_function_inv(named.rgb.r),
			srgb_transfer_function_inv(named.rgb.g),
			srgb_transfer_function_inv(named.rgb.b),
		};
		Lab lab = linear_srgb_to_oklab(linear);
		Lch lch = srgb_to_oklch(named.rgb);
		HSL hsl = srgb_to_okhsl(named.rgb);
		HSV hsv = srgb_to_okhsv(named.rgb);

		std::cout << "    {\"name\":\"" << named.name << "\",\"srgb\":";
		print_array(named.rgb);
		std::cout << ",\"linear\":";
		print_array(linear);
		std::cout << ",\"okLab\":";
		print_array(lab);
		std::cout << ",\"okLch\":";
		print_array(lch);
		std::cout << ",\"okHsl\":";
		print_array(hsl);
		std::cout << ",\"okHsv\":";
		print_array(hsv);
		std::cout << "}" << (index + 1 == srgb_cases.size() ? "\n" : ",\n");
	}

	std::cout << "  ],\n  \"linearClippingCases\": [\n";
	for (size_t index = 0; index < clipping_cases.size(); ++index) {
		NamedLinearRGB named = clipping_cases[index];
		std::cout << "    {\"name\":\"" << named.name << "\",\"linear\":";
		print_array(named.rgb);
		std::cout << ",\"preserveChroma\":";
		print_array(gamut_clip_preserve_chroma(named.rgb));
		std::cout << ",\"projectToPointFive\":";
		print_array(gamut_clip_project_to_0_5(named.rgb));
		std::cout << ",\"projectToCusp\":";
		print_array(gamut_clip_project_to_L_cusp(named.rgb));
		std::cout << ",\"adaptivePointFive\":";
		print_array(gamut_clip_adaptive_L0_0_5(named.rgb));
		std::cout << ",\"adaptiveCusp\":";
		print_array(gamut_clip_adaptive_L0_L_cusp(named.rgb));
		std::cout << "}" << (index + 1 == clipping_cases.size() ? "\n" : ",\n");
	}
	std::cout << "  ]\n}\n";
}
