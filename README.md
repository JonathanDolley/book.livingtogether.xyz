To convert tikz pictures to png images for including in documents do the following.

1. Open the terminal.
2. cd diagrams
3. Run "latex filename"
4. Run "dvips filename"
5. Run "gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pngalpha -r300 -sOutputFile=output.png input.ps"

e.g. "gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pngalpha -r300 -sOutputFile=stakeholders.png stakeholders.ps"

e.g. "gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pngalpha -r300 -sOutputFile=federation.png federation.ps"

e.g. "gs -dSAFER -dBATCH -dNOPAUSE -sDEVICE=pngalpha -r300 -sOutputFile=timeline.png timeline.ps"

- dSAFER: Runs Ghostscript in safe mode.
- dBATCH: Exits Ghostscript after processing the file.
- dNOPAUSE: Does not pause after each page.
- sDEVICE=pngalpha: Sets the output device to PNG with alpha channel support.
- r300: Sets the resolution to 300 DPI (adjust as needed).
- sOutputFile=output.png: Specifies the output PNG file name.
- input.ps: The name of your input PS file.

Replace output.png with your desired output file name and input.ps with the name of your PS file. This command will convert your PostScript file to a PNG image with the specified resolution.
