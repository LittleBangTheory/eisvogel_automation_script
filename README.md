# Eisvogel automation

This little script aims at automating the use of the [Eisvogel template](https://github.com/Wandmalfarbe/pandoc-latex-template/tree/master) by [Pascal Wagler](https://github.com/Wandmalfarbe). Feel free to use it, modify it, and do whatever you want with it.

I tried my best to remember all the dependencies, I had to install to make it work, but I might have forgotten some. If you encounter any issue, please let me know.

## Installation

Install [Pandoc](https://pandoc.org/installing.html) and [LaTeX](https://en.wikibooks.org/wiki/LaTeX/Installation#Distributions).

Install the [Eisvogel template](https://github.com/Wandmalfarbe/pandoc-latex-template/tree/master).

Execute the following : 

```bash
sudo apt update
sudo apt install texlive-xetex texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra texlive-science
```

## Usage

The following options are supported :

```bash
$ ./script.sh 
Usage: ./script.sh [options] <markdown-file>
Options:
    --author/-a author            Specify the author
    --date/-d date                Specify the date
    --keywords/-k keywords        Specify the keywords
    --margin/-m margin            Specify the margin
    --footer/-f footer            Specify the footer
    --toc/-t                      Include table of contents
    --output-file/-o output-file  Specify the output file
    --help/-h                     Display this help message
```

If you wish to change default values, go to the configuration file.

## Explanation

The script isn't really clean, it is mostly useful, here are a few things you should know :
- Your markdown file is copied as `temp.md` and then modified, so no changes are made to your original file. BUT, if you already have a `temp.md` file, it will ask you if you want to overwrite it.
- The script takes your first first-level title as the title of the document, then remove it from the markdown.
- Because a markdown file is only supposed to have one first-level title, and that it is removed from the markdown, the script then removes a `#` from all the titles in the markdown, to bring them one level higher. If you have multiple first-level titles, don't worry, the script won't delete the `#` from them and transform them into plain text, it will just bring the second-level titles to first-level beside them.