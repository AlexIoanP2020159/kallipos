#!/bin/bash
FONT="Open Sans"

if [ ! -d book ]; then
  echo "Directory does not exist. Creating book directory..."
  mkdir book
else
  echo "book directory already exists."
fi

echo "Assembling and preprocessing all the sources files..."

pandoc text/pre.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to html > book/pre.html
pandoc text/intro.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to html > book/intro.html

for filename in text/ch*.txt; do
   [ -e "$filename" ] || continue
   pandoc --lua-filter=extras.lua "$filename" --to markdown | pandoc --lua-filter=extras.lua --to markdown | pandoc --lua-filter=filter.lua --to markdown | pandoc --lua-filter=epigraph.lua --to markdown | pandoc --lua-filter=figure.lua --to markdown | pandoc --lua-filter=footnote.lua --to markdown | pandoc --filter pandoc-fignos --to markdown | pandoc --metadata-file=meta.yml --top-level-division=chapter --citeproc --bibliography=bibliography/"$(basename "$filename" .txt).bib" --reference-location=section --wrap=none --to html > book/"$(basename "$filename" .txt).html"
done

pandoc text/web.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to html > book/web.html
pandoc text/bio.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to html > book//bio.html

for filename in text/apx*.txt; do
   [ -e "$filename" ] || continue
   pandoc --lua-filter=extras.lua "$filename" --to markdown | pandoc --lua-filter=extras.lua --to markdown | pandoc --lua-filter=epigraph.lua --to markdown | pandoc --lua-filter=figure.lua --to markdown | pandoc --filter pandoc-fignos --to markdown | pandoc --metadata-file=meta.yml --top-level-division=chapter --citeproc --bibliography=bibliography/"$(basename "$filename" .txt).bib" --reference-location=section --to html > book/"$(basename "$filename" .txt).html"
done

echo "Merging html files... "
pandoc --quiet -s book/*.html -o book/index.html --metadata title="Ο Προγραμματισμός της Διάδρασης"

echo "Converting to pdf... "
pandoc -N --quiet --variable "geometry=margin=1.2in" --variable mainfont="$FONT" --variable sansfont="$FONT" --variable monofont="$FONT" --variable fontsize=12pt --variable version=2.0 book/book.tex  --pdf-engine=xelatex --toc -o book/book.pdf
echo "Finished converting to pdf. "

echo "Converting to epub..."
pandoc -o book/book.epub book/book.html --metadata title="book"

echo "Converting to html..."
echo "#lang pollen" >> book/book.html.pmd
cat book/book.html >> book/book.html.pmd
raco pollen render book/index.html.pmd
rm -rf "book/compiled"
rm "book/book.html.pmd"

echo "Book finished building."
