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

export ASC_KEY_ID="8VLCWXKF8U"
export ASC_ISSUER_ID="e3cc2834-4f26-41b2-8ca9-bc091377448a"
export ASC_PRIVATE_KEY_PATH="/Users/alex.lombry/AuthKey_8VLCWXKF8U.p8"
