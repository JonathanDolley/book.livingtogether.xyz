To publish run "quarto publish netlify"

To convert individual tikz pictures to png images for including in documents do the following.

Run "tikz2png filepath.tex" in terminal to create the png using poppler.

This command runs the following function saved in the ~/zshrc file:

function tikz2png() {
    # 1. Check input
    if [ -z "$1" ]; then
        echo "Usage: tikz2png path/to/filename.tex"
        return 1
    fi

    local input_file="$1"
    # Get the folder where the .tex file lives
    local dir_name=$(dirname "$input_file")
    # Get the filename without extension
    local base_name=$(basename "$input_file" .tex)

    echo "⚙️  Processing ${base_name} inside ${dir_name}/..."

    # 2. Compile specifically into the target directory
    # -output-directory ensures the .pdf ends up next to the .tex, not in root
    pdflatex -output-directory "$dir_name" "$input_file" > /dev/null

    # 3. Check if PDF was created successfully
    if [ ! -f "${dir_name}/${base_name}.pdf" ]; then
        echo "❌ Error: PDF creation failed. Check for LaTeX errors."
        return 1
    fi

    echo "📸 Converting PDF to PNG..."
    
    # 4. Convert using the full path
    pdftoppm -png -r 300 -singlefile "${dir_name}/${base_name}.pdf" "${dir_name}/${base_name}"

    # 5. Cleanup the specific artifacts in that folder
    rm "${dir_name}/${base_name}.pdf" "${dir_name}/${base_name}.log" "${dir_name}/${base_name}.aux"

    echo "✅ Success! Saved to ${dir_name}/${base_name}.png"
}
