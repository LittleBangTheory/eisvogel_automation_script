#!/bin/bash

# Bash script to convert a markdown file to a PDF using pandoc.
# Probably a lot of dependencies are required, but I don't remember which ones I installed, so run it and see for yourself :)

#Path to config file
config_file="config.conf"

# Default values (can be overridden by config file if it exists)
author="My Name"
date=$(date +"%Y-%m-%d")  # Default date is today's date
keywords=""
footer_center="Footer text"
subtitle=""
toc=""
margin=2.5
font_size=12
output="output.pdf"
titlepage_logo=""
logo_width=10
titlepage="true" # have a title page
titlepage_color="789D4A"
titlepage_text_color="FFFFFF"
titlepage_rule_color="FFFFFF"
titlepage_rule_height=5 # in cm
toc_depth=5
numbersections="true"
toc_own_page="true"
colorlinks="true"
footnotes_pretty="true"
footnotes_disable_backlinks="false"
table_use_row_colors="true"
use_long_tables="true"

# Function to show usage
usage() {
  echo "Usage: $0 [options] <markdown-file>"
  echo "Options:"
  echo "  --config/-c config-file       Specify the config file"
  echo "  --author/-a author            Specify the author"
  echo "  --date/-d date                Specify the date"
  echo "  --keywords/-k keywords        Specify the keywords"
  echo "  --margin/-m margin            Specify the margin"
  echo "  --footer/-f footer            Specify the footer"
  echo "  --toc/-t                      Include table of contents"
  echo "  --output-file/-o output-file  Specify the output file"
  echo "  --help/-h                     Display this help message"
  exit 1
}

# Parse options
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -a | --author )
    shift
    author=$1
    ;;
  -c | --config )
    shift
    config_file=$1
    ;;
  -d | --date )
    shift
    date=$1
    ;;
  -k | --keywords )
    shift
    keywords=$1
    ;;
  -m | --margin )
    shift
    margin=$1
    ;;
  -f | --footer )
    shift
    footer_center=$1
    ;;
  -t | --toc )
    toc="--toc"
    ;;
  -h | --help )
    usage
    ;;
  -o | --output-file)
    shift
    output=$1
    ;;
  *)
    usage
    ;;
esac; shift; done

if [[ "$1" == '--' ]]; then shift; fi

# Ensure markdown file is provided
if [ -z "$1" ]; then
  usage
fi

# File input
markdown_file=$1

# Ensure the file exists
if [ ! -f "$markdown_file" ]; then
  echo "File not found!"
  exit 1
fi

# Load default values from config file if it exists
if [ -f "$config_file" ]; then
  source "$config_file"
fi

# Extract the title from the first # heading
title=$(grep -m 1 '^# ' "$markdown_file" | sed 's/^# //')

# Ensure a title was found
if [ -z "$title" ]; then
  echo "No title found in the markdown file (no '# ' heading found)."
  exit 1
fi

# Ensure the title page logo exists if provided
if [ -n "$titlepage_logo" ] && [ ! -f "$titlepage_logo" ]; then
  echo "Title page logo not found!"
  exit 1
fi

# Generate a temporary file in the temporary folder
tmp_file=$(mktemp)

# Add metadata at the beginning of the markdown file
cat <<EOF > "$tmp_file"
---
titlepage: $titlepage
titlepage-color: $titlepage_color
titlepage-text-color: $titlepage_text_color
titlepage-rule-color: $titlepage_rule_color
titlepage-rule-height: $titlepage_rule_height
titlepage-logo: "$titlepage_logo"
toc-depth: $toc_depth
numbersections: $numbersections
toc-own-page: $toc_own_page
colorlinks: $colorlinks
footnotes-pretty: $footnotes_pretty
logo-width : ${logo_width}cm
title: "$title"
author: [$author]
date: "$date"
keywords: [$keywords]
geometry: margin=${margin}cm
fontsize: $font_size
footer-center: $footer_center
disable-header-and-footer: $disable_header_and_footer
footnotes-disable-backlinks: $footnotes_disable_backlinks
table-use-row-colors: $table_use_row_colors
use-long-tables: $use_long_tables
listings-no-page-break: true
subtitle: $subtitle
header-includes: |
    \RedeclareSectionCommands[
      afterskip=1.25ex plus .1ex
    ]{paragraph,subparagraph}
    \usepackage{amsmath}
    \usepackage{stmaryrd}
    \usepackage{svg}
---
EOF

# Copy the markdown file to the temp file
cat "$markdown_file" >> "$tmp_file"

# Remove the first level heading line and remove one # from every other heading
sed -i '0,/^# /{//!b;d}; s/^## /# /; s/^### /## /; s/^#### /### /; s/^##### /#### /; s/^###### /##### /' "$tmp_file"

# Save the new file as "temp.md" in the temporary folder
temp_file_no_ext="temp"
temp_file_path="$temp_file_no_ext.md"
mv "$tmp_file" "$temp_file_path"

# Run mmdc on the temp file
images_ext="png"
mmdc -i "$temp_file_path" -o "$temp_file_path" -e $images_ext -b transparent -t neutral -w 2500 -H 1080

# Create command
command="pandoc $temp_file_path -f markdown-raw_tex -o $output --pdf-engine=xelatex --from markdown --template eisvogel --listings --list-tables $toc"

# Execute the command
eval "$command" && echo "PDF generated as $output"

# Remove the temporary files
rm $temp_file_path
if ls $temp_file_no_ext-*.$images_ext 1> /dev/null 2>&1; then
    # If files exist, delete them
    rm $temp_file_no_ext-*.$images_ext
fi