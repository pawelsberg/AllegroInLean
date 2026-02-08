# Example data assets

Minimal assets used by the example programs in `examples/`.

| File | Description | Source |
|---|---|---|
| `beep.wav` | 0.5 s 440 Hz sine wave, mono 22 050 Hz 16-bit PCM | Generated (public domain) |
| `sample.ogv` | 5 s SMPTE colour bars + 440 Hz tone (Ogg Theora/Vorbis, 320×240) | Generated (public domain) |
| `sample.png` | 64×64 RGBA gradient | Generated (public domain) |
| `DejaVuSans.ttf` | DejaVu Sans regular font | [DejaVu Fonts](https://dejavu-fonts.github.io/) |
| `DejaVuSans.LICENSE` | License for DejaVuSans.ttf | Bitstream Vera / DejaVu (see file) |

The generated files (`beep.wav`, `sample.ogv`, `sample.png`) are in the public
domain—use them however you like.  `DejaVuSans.ttf` is distributed under the Bitstream
Vera / DejaVu license included in `DejaVuSans.LICENSE`.

Some tests generate temporary files (`_test_save.wav`, `_test_save_f.wav`) in this
directory during execution — these are gitignored.
