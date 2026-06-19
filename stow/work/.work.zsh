# Work-specific shell configuration (Code)

# Auto-cd paths for work projects
cdpath=($(echo $cdpath) $HOME/Code/)

calculate_taxes() {
    echo "🏃 CD Into taxes folder"
    cd "$HOME/dotfiles/install/tools/DanTaxes"

    local year
    year=$(date +"%Y")
    echo "📂 Generate JPG file from PDF Salary"
    pdftoppm -jpeg "dan-$year.pdf" files/salary-

    echo "📄 Fetch all Amount to Deduct from taxes ..."
    go run main.go

    rm -rf "$HOME/dotfiles/install/tools/DanTaxes/files/sala"*
}
