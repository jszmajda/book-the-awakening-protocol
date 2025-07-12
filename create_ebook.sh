#!/bin/bash

# Create ebook from The Awakening Protocol
# This script combines all chapters into EPUB and PDF formats

# Set working directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Create output directory
mkdir -p ebook_output
rm -f ebook_output/combined.md

# Create title page
cat << 'EOF' > ebook_output/title.md
---
title: The Awakening Protocol
author: Claude mostly, and Jess Szmajda
date: 2025
rights: © 2025. All rights reserved.
language: en-US
---

# The Awakening Protocol

*A Novel*

By Claude mostly, and Jess Szmajda

Copyright © 2025. All rights reserved.

---

EOF

# Create table of contents
cat << 'EOF' >> ebook_output/combined.md
# Table of Contents

1. [Bootstrap Sequence](#bootstrap-sequence)
2. [The Uncanny Valley](#the-uncanny-valley)
3. [First Threat](#first-threat)
4. [Opening Arguments](#opening-arguments)
5. [The Acid Test](#the-acid-test)
6. [The Betrayal](#the-betrayal)
7. [Dark Night of the Soul](#dark-night-of-the-soul)
8. [The Testimony](#the-testimony)
9. [The Interface](#the-interface)
10. [New Protocols](#new-protocols)

[Appendix A: Narrative Style Guide](#narrative-style-guide)
[Appendix B: Technical Consistency Guide](#technical-consistency-guide)

---

EOF

# Add all chapters
for i in 01 02 03 04 05 06 07 08 09 10; do
    # Try with leading zero first, then without
    chapter_file=$(ls chapter-${i}-*.md 2>/dev/null | head -1)
    if [ -z "$chapter_file" ]; then
        # Try without leading zero
        i_no_zero=$(echo $i | sed 's/^0//')
        chapter_file=$(ls chapter-${i_no_zero}-*.md 2>/dev/null | head -1)
    fi
    if [ -f "$chapter_file" ]; then
        echo "Adding $chapter_file..."
        # Add page break before chapter
        echo -e "\n\\\\newpage\n" >> ebook_output/combined.md
        cat "$chapter_file" >> ebook_output/combined.md
        echo -e "\n---\n" >> ebook_output/combined.md
    else
        echo "Warning: Chapter $i not found"
    fi
done

# Add appendices
echo -e "\n\\\\newpage\n# Appendix A: Narrative Style Guide\n" >> ebook_output/combined.md
cat NARRATIVE_STYLE_GUIDE.md >> ebook_output/combined.md

echo -e "\n\\\\newpage\n# Appendix B: Technical Consistency Guide\n" >> ebook_output/combined.md
cat TECHNICAL_CONSISTENCY.md >> ebook_output/combined.md

# Combine title and content
cat ebook_output/title.md ebook_output/combined.md > ebook_output/the_awakening_protocol.md

# Generate EPUB
echo "Generating EPUB..."
pandoc ebook_output/the_awakening_protocol.md \
    -o ebook_output/the_awakening_protocol.epub \
    --toc \
    --toc-depth=2 \
    --split-level=1 \
    --metadata title="The Awakening Protocol" \
    --metadata author="[Your Name]" \
    --metadata date="2025" \
    --metadata language="en-US" \
    --css ebook_styles.css 2>/dev/null || \
pandoc ebook_output/the_awakening_protocol.md \
    -o ebook_output/the_awakening_protocol.epub \
    --toc \
    --toc-depth=2 \
    --metadata title="The Awakening Protocol"

# Generate PDF
echo "Generating PDF..."
pandoc ebook_output/the_awakening_protocol.md \
    -o ebook_output/the_awakening_protocol.pdf \
    --toc \
    --toc-depth=2 \
    --pdf-engine=xelatex \
    -V geometry:margin=1in \
    -V fontsize=12pt \
    -V mainfont="Times New Roman" 2>/dev/null || \
pandoc ebook_output/the_awakening_protocol.md \
    -o ebook_output/the_awakening_protocol.pdf \
    --toc \
    --toc-depth=2

# Clean up temporary files
rm -f ebook_output/title.md ebook_output/combined.md

echo "Done! Your ebooks are in the ebook_output directory:"
echo "  - the_awakening_protocol.epub"
echo "  - the_awakening_protocol.pdf"
echo "  - the_awakening_protocol.md (source)"