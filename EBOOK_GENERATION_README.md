# Ebook Generation Guide for The Awakening Protocol

This directory contains scripts to generate professional ebooks from the markdown chapters.

## Prerequisites

### Required:
- **pandoc** - The universal document converter
  - macOS: `brew install pandoc`
  - Ubuntu/Debian: `sudo apt-get install pandoc`
  - Windows: Download from [pandoc.org](https://pandoc.org)

### Optional (for advanced features):
- **XeLaTeX** - For better PDF formatting with custom fonts
  - macOS: `brew install --cask mactex` (large download)
  - Ubuntu/Debian: `sudo apt-get install texlive-xetex`
  
- **Calibre** - For MOBI/Kindle format generation
  - macOS: `brew install --cask calibre`
  - Ubuntu/Debian: `sudo apt-get install calibre`

## Quick Start

### Basic Generation (EPUB + PDF)
```bash
./create_ebook.sh
```

This creates:
- `ebook_output/the_awakening_protocol.epub` - For most e-readers
- `ebook_output/the_awakening_protocol.pdf` - For printing/reading on computer
- `ebook_output/the_awakening_protocol.md` - Combined source markdown

### Advanced Generation (with all features)
```bash
./create_ebook_advanced.sh --mobi --verbose
```

Options:
- `--mobi` - Also generate MOBI format for Kindle (requires Calibre)
- `--keep-temp` - Keep temporary files for debugging
- `--verbose` - Show detailed progress
- `--help` - Show all options

## Customization

### 1. Update Author Information
Edit the scripts and replace:
- `[Your Name Here]` with your actual name
- `[Your Publisher]` with publisher name (or self-published)
- Update copyright year if needed

### 2. Add a Cover Image
Place a cover image named `cover.jpg` in the story directory for automatic inclusion in EPUB.

### 3. Customize Styling
The advanced script creates custom CSS. Edit the CSS section in `create_ebook_advanced.sh` to change:
- Fonts
- Line spacing
- Chapter heading styles
- Page margins

### 4. Add Front/Back Matter
In the advanced script, you can add:
- Dedication (replace `[Your dedication here]`)
- Author bio (replace `[Your bio here]`)
- Acknowledgments (replace `[Your acknowledgments here]`)

## Output Formats

### EPUB
- Best for: E-readers (Kobo, Nook, Apple Books)
- Features: Reflowable text, custom fonts, table of contents
- File size: ~500KB

### PDF
- Best for: Printing, reading on computer
- Features: Fixed layout, page numbers, professional formatting
- File size: ~1-2MB

### MOBI (optional)
- Best for: Amazon Kindle devices
- Features: Kindle-specific formatting
- File size: ~800KB

## Troubleshooting

### "pandoc: command not found"
Install pandoc first (see Prerequisites above)

### PDF generation fails
- Try without XeLaTeX: Remove the `--pdf-engine=xelatex` line from script
- Or install XeLaTeX for better formatting

### MOBI generation skipped
- Install Calibre first
- Or use Amazon's Kindle Previewer to convert EPUB to MOBI

### Chapters not found
- Ensure all chapter files follow the pattern: `chapter-XX-title.md`
- Run the script from the story directory

## Advanced Customization

### Different Chapter Organization
Edit the chapter loop in the scripts to change order or skip chapters.

### Custom Metadata
Edit the metadata section to add:
- ISBN
- Series information
- Additional subjects/genres
- Language variants

### Multiple Formats
The scripts can be modified to generate:
- HTML websites
- LaTeX documents
- Word documents
- And more (see pandoc documentation)

## Distribution

Once generated, you can:
1. Upload EPUB to most ebook stores (Apple, Kobo, Google Play)
2. Convert EPUB to MOBI for Amazon KDP
3. Use PDF for print-on-demand services
4. Share the source markdown for collaborative editing

Remember to proofread the generated files before distribution!