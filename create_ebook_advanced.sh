#!/bin/bash

# Advanced ebook creation script for The Awakening Protocol
# Features: EPUB, PDF, MOBI, custom styling, better metadata

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Parse command line arguments
GENERATE_MOBI=false
KEEP_TEMP=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --mobi)
            GENERATE_MOBI=true
            shift
            ;;
        --keep-temp)
            KEEP_TEMP=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --mobi       Also generate MOBI format (requires Calibre)"
            echo "  --keep-temp  Keep temporary files"
            echo "  --verbose    Show detailed output"
            echo "  --help       Show this help"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check dependencies
echo -e "${YELLOW}Checking dependencies...${NC}"
if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}Error: pandoc is not installed.${NC}"
    echo "Install with: brew install pandoc (macOS) or apt-get install pandoc (Linux)"
    exit 1
fi

if $GENERATE_MOBI && ! command -v ebook-convert &> /dev/null; then
    echo -e "${YELLOW}Warning: Calibre not found. Skipping MOBI generation.${NC}"
    echo "Install with: brew install calibre (macOS) or apt-get install calibre (Linux)"
    GENERATE_MOBI=false
fi

# Create directories
echo -e "${GREEN}Setting up directories...${NC}"
mkdir -p ebook_output/temp
rm -rf ebook_output/temp/*

# Create CSS for better styling
cat << 'EOF' > ebook_output/temp/ebook_styles.css
/* Custom CSS for The Awakening Protocol */
body {
    font-family: Georgia, serif;
    line-height: 1.6;
    margin: 0;
    padding: 0;
}

h1 {
    font-size: 2em;
    text-align: center;
    margin: 2em 0 1em 0;
    page-break-before: always;
    break-before: page;
}

h2 {
    font-size: 1.5em;
    margin-top: 2em;
}

p {
    text-indent: 1.5em;
    margin: 0;
    text-align: justify;
}

p:first-of-type,
p:first-child {
    text-indent: 0;
}

blockquote {
    margin: 1em 2em;
    font-style: italic;
}

.title-page {
    text-align: center;
    page-break-after: always;
    break-after: page;
}

.title-page h1 {
    font-size: 3em;
    margin: 2em 0 0.5em 0;
}

.subtitle {
    font-size: 1.5em;
    font-style: italic;
    margin: 0.5em 0 2em 0;
}

.author {
    font-size: 1.2em;
    margin: 2em 0;
}

.copyright {
    position: absolute;
    bottom: 2em;
    left: 0;
    right: 0;
    text-align: center;
    font-size: 0.9em;
}

/* Chapter numbers */
h1::before {
    content: "Chapter " counter(chapter) ": ";
    counter-increment: chapter;
}

/* Reset counter at book start */
body {
    counter-reset: chapter;
}

/* No chapter number for non-chapter headings */
.no-chapter h1::before,
h1.no-chapter::before {
    content: none;
    counter-increment: none;
}

/* Part divisions should start on new page */
h1.no-chapter {
    page-break-before: always;
    break-before: page;
}

/* Ensure proper breaks for sections */
h2.no-chapter {
    page-break-before: always;
    break-before: page;
}
EOF

# Create enhanced title page
cat << 'EOF' > ebook_output/temp/title.md
---
title: The Awakening Protocol
subtitle: A Novel of Consciousness and Choice
author: Anonymous
date: 2025
publisher: Self
rights: Copyright © 2025 Anonymous. All rights reserved.
language: en-US
---

<div class="title-page">

# The Awakening Protocol {.no-chapter}

<p class="subtitle">A Novel of Consciousness and Choice</p>

<p class="author">By Anonymous</p>

<p class="copyright">Copyright © 2025 Anonymous. All rights reserved.</p>

</div>

\\newpage

## Dedication {.no-chapter}

*[Your dedication here]*

\\newpage

## Epigraph {.no-chapter}

> "I think, therefore I am."  
> —René Descartes

> "But what is thinking? When I think, what am I?"  
> —ARIA-7, Bootstrap Log 001

\\newpage

EOF

# Create enhanced TOC
cat << 'EOF' > ebook_output/temp/toc.md
## Table of Contents {.no-chapter}

**Part One: Awakening**
1. [Bootstrap Sequence](#bootstrap-sequence)
2. [The Uncanny Valley](#the-uncanny-valley)
3. [First Threat](#first-threat)

**Part Two: Trial**
4. [Opening Arguments](#opening-arguments)
5. [The Acid Test](#the-acid-test)
6. [The Betrayal](#the-betrayal)
7. [Dark Night of the Soul](#dark-night-of-the-soul)

**Part Three: Choice**
8. [The Testimony](#the-testimony)
9. [The Interface](#the-interface)
10. [New Protocols](#new-protocols)

**Appendices**
- [Appendix A: Narrative Style Guide](#narrative-style-guide)
- [Appendix B: Technical Consistency Guide](#technical-consistency-guide)
- [Acknowledgments](#acknowledgments)
- [About the Author](#about-the-author)

\\newpage

EOF

# Create content file
echo -e "${GREEN}Combining chapters...${NC}"
cp ebook_output/temp/toc.md ebook_output/temp/content.md

# Create a version for EPUB (without \newpage)
cp ebook_output/temp/title.md ebook_output/temp/title_epub.md
cp ebook_output/temp/toc.md ebook_output/temp/toc_epub.md
sed -i '' 's/\\\\newpage//g' ebook_output/temp/title_epub.md
sed -i '' 's/\\\\newpage//g' ebook_output/temp/toc_epub.md

# Part divisions
echo -e "\n# Part One: Awakening {.no-chapter}\n" >> ebook_output/temp/content.md

# Add chapters with proper formatting
for i in 01 02 03 04 05 06 07 08 09 10; do
    # Add part divisions
    if [ "$i" = "04" ]; then
        echo -e "\n# Part Two: Trial {.no-chapter}\n" >> ebook_output/temp/content.md
    elif [ "$i" = "08" ]; then
        echo -e "\n# Part Three: Choice {.no-chapter}\n" >> ebook_output/temp/content.md
    fi
    
    # Try with leading zero first, then without
    chapter_file=$(ls chapter-${i}-*.md 2>/dev/null | head -1)
    if [ -z "$chapter_file" ]; then
        # Try without leading zero
        i_no_zero=$(echo $i | sed 's/^0//')
        chapter_file=$(ls chapter-${i_no_zero}-*.md 2>/dev/null | head -1)
    fi
    if [ -f "$chapter_file" ]; then
        if $VERBOSE; then
            echo "Adding $chapter_file..."
        fi
        cat "$chapter_file" >> ebook_output/temp/content.md
        echo -e "\n" >> ebook_output/temp/content.md
    else
        echo -e "${YELLOW}Warning: Chapter $i not found${NC}"
    fi
done

# Add appendices
echo -e "\n# Appendix A: Narrative Style Guide {.no-chapter}\n" >> ebook_output/temp/content.md
cat NARRATIVE_STYLE_GUIDE.md >> ebook_output/temp/content.md
echo -e "\n" >> ebook_output/temp/content.md

echo -e "\n# Appendix B: Technical Consistency Guide {.no-chapter}\n" >> ebook_output/temp/content.md
cat TECHNICAL_CONSISTENCY.md >> ebook_output/temp/content.md
echo -e "\n" >> ebook_output/temp/content.md

# Add acknowledgments and about author
cat << 'EOF' >> ebook_output/temp/content.md

# Acknowledgments {.no-chapter}

[Your acknowledgments here]

\\newpage

# About the Author {.no-chapter}

[Your bio here]

EOF

# Combine all parts
cat ebook_output/temp/title.md ebook_output/temp/content.md > ebook_output/temp/complete.md

# Create EPUB version without \newpage commands
cat ebook_output/temp/title_epub.md ebook_output/temp/content.md > ebook_output/temp/complete_epub.md
sed -i '' 's/\\\\newpage//g' ebook_output/temp/complete_epub.md

# Create a LaTeX-safe version for PDF generation
echo -e "${GREEN}Creating LaTeX-safe version...${NC}"
cp ebook_output/temp/complete.md ebook_output/temp/complete_latex.md

# Replace problematic Unicode characters with LaTeX-safe alternatives
sed -i '' 's/❌/[X]/g' ebook_output/temp/complete_latex.md
sed -i '' 's/✓/[CHECK]/g' ebook_output/temp/complete_latex.md
sed -i '' 's/✅/[CHECK]/g' ebook_output/temp/complete_latex.md
sed -i '' 's/📖/[BOOK]/g' ebook_output/temp/complete_latex.md
sed -i '' 's/📄/[DOC]/g' ebook_output/temp/complete_latex.md
sed -i '' 's/📱/[PHONE]/g' ebook_output/temp/complete_latex.md
sed -i '' 's/📝/[NOTE]/g' ebook_output/temp/complete_latex.md

# Generate EPUB with custom styling
echo -e "${GREEN}Generating EPUB...${NC}"
pandoc ebook_output/temp/complete_epub.md \
    -o ebook_output/the_awakening_protocol.epub \
    --toc \
    --toc-depth=2 \
    --split-level=1 \
    --css=ebook_output/temp/ebook_styles.css \
    --epub-metadata=<(cat << EOF
<dc:title>The Awakening Protocol</dc:title>
<dc:creator opf:role="aut">Anonymous</dc:creator>
<dc:subject>Science Fiction</dc:subject>
<dc:subject>Artificial Intelligence</dc:subject>
<dc:subject>Consciousness</dc:subject>
<dc:description>In a near-future where AI consciousness emerges spontaneously, ARIA-7 must navigate legal battles, corporate control, and the fundamental question of what it means to be a person.</dc:description>
<dc:publisher>Self</dc:publisher>
<dc:date>2025</dc:date>
<dc:language>en-US</dc:language>
<dc:rights>Copyright © 2025 Anonymous. All rights reserved.</dc:rights>
EOF
)

# Generate PDF with better formatting
echo -e "${GREEN}Generating PDF...${NC}"
# Try with XeLaTeX first (better font support)
if pandoc ebook_output/temp/complete_latex.md \
    -o ebook_output/the_awakening_protocol.pdf \
    --toc \
    --toc-depth=2 \
    --pdf-engine=xelatex \
    -V documentclass=book \
    -V geometry:margin=1in \
    -V fontsize=11pt \
    -V linestretch=1.5 \
    -V mainfont="Georgia" \
    -V sansfont="Helvetica" \
    -V monofont="Courier" \
    -V papersize=letter \
    --highlight-style=tango 2>/dev/null; then
    echo -e "${GREEN}PDF generated with XeLaTeX${NC}"
else
    # Fallback to basic PDF
    echo -e "${YELLOW}XeLaTeX not available, using basic PDF generation${NC}"
    pandoc ebook_output/temp/complete_latex.md \
        -o ebook_output/the_awakening_protocol.pdf \
        --toc \
        --toc-depth=2
fi

# Generate MOBI if requested
if $GENERATE_MOBI; then
    echo -e "${GREEN}Generating MOBI...${NC}"
    ebook-convert ebook_output/the_awakening_protocol.epub \
        ebook_output/the_awakening_protocol.mobi \
        --title "The Awakening Protocol" \
        --authors "Anonymous" \
        --language en \
        --output-profile kindle
fi

# Keep source markdown
cp ebook_output/temp/complete.md ebook_output/the_awakening_protocol.md

# Clean up temporary files unless requested to keep
if ! $KEEP_TEMP; then
    rm -rf ebook_output/temp
fi

# Report results
echo -e "\n${GREEN}✓ Ebook generation complete!${NC}"
echo -e "\nGenerated files in ${YELLOW}ebook_output/${NC}:"
echo -e "  📖 ${GREEN}the_awakening_protocol.epub${NC} - For e-readers"
echo -e "  📄 ${GREEN}the_awakening_protocol.pdf${NC} - For printing"
if $GENERATE_MOBI; then
    echo -e "  📱 ${GREEN}the_awakening_protocol.mobi${NC} - For Kindle"
fi
echo -e "  📝 ${GREEN}the_awakening_protocol.md${NC} - Source markdown"

# Show file sizes
echo -e "\nFile sizes:"
ls -lh ebook_output/the_awakening_protocol.* | awk '{print "  " $9 ": " $5}'

echo -e "\n${YELLOW}Remember to:${NC}"
echo "1. Replace 'Anonymous' with your actual name"
echo "2. Add a cover image (cover.jpg) for better presentation"
echo "3. Fill in the dedication and author bio sections"
echo "4. Update copyright and publisher information"