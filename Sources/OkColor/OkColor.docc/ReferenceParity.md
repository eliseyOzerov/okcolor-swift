# Reference Parity

OkColor keeps parity fixtures and reference sources in the repository so changes can be checked against Ottosson's C++ implementation.

## Overview

The original C++ reference sources are checked in under `ReferenceSources/OkColor`. Swift source files are split by model and helper area, with comments above important constant blocks naming the corresponding C++ functions.

The parity fixture generator lives at `ReferenceSources/OkColor/generate_cpp_parity_fixtures.cpp`. Its checked-in output, `Tests/OkColorTests/Fixtures/CppParityFixtures.json`, is loaded by the Swift test suite through `Bundle.module`.

The parity tests cover:

- sRGB transfer functions
- sRGB to Oklab and Oklab to sRGB conversion
- OkLch conversion
- OkHSL and OkHSV conversion
- Gamut cusp and intersection helpers
- All five ``OkGamutClipping`` strategies

One intentional difference is kept for parity with the Dart package this Swift package mirrors: OkHSV scale guards use `1e-10` where the C++ reference uses `0.f`. That avoids division-by-zero edge cases and matches the Flutter package behavior.
