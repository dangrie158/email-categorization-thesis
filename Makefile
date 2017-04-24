PY=python
PANDOC=pandoc

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/source
OUTPUTDIR=$(BASEDIR)/output
TEMPLATEDIR=$(INPUTDIR)/templates
STYLEDIR=$(BASEDIR)/style

BIBFILE=$(INPUTDIR)/references.bib


help:
	@echo ' 																	  '
	@echo 'Makefile for the Markdown thesis                                       '
	@echo '                                                                       '
	@echo 'Usage:                                                                 '
	@echo '   make html                        generate a web version             '
	@echo '   make pdf                         generate a PDF file  			  '
	@echo '   make docx	                       generate a Docx file 			  '
	@echo '   make tex	                       generate a Latex file 			  '
	@echo '                                                                       '
	@echo ' 																	  '
	@echo ' 																	  '
	@echo 'get local templates with: pandoc -D latex/html/etc	  				  '
	@echo 'or generic ones from: https://github.com/jgm/pandoc-templates		  '

pdf:
	rm -f ./source/references.bib.bak
	sed -i.bak 's/phdthesis/masterthesis/' ./source/references.bib
	pandoc "$(INPUTDIR)"/*.md \
	"$(INPUTDIR)"/metadata.yml \
	--filter pandoc-shortcaption \
	--filter pandoc-crossref \
	--filter pandoc-citeproc \
	--bibliography="$(BIBFILE)" \
	-o "$(OUTPUTDIR)/thesis.pdf" \
	-H "$(STYLEDIR)/preamble.tex" \
	--template="$(STYLEDIR)/template.tex" \
	--highlight-style pygments \
	-V fontsize=12pt \
	-V papersize=a4paper \
	-V documentclass:report \
	-N \
	--latex-engine=xelatex \
	--csl="$(STYLEDIR)/ref_format.csl" \
	 2>pandoc.log
#	--verbose

tex:
	rm -f ./source/references.bib.bak
	sed -i.bak 's/phdthesis/masterthesis/' ./source/references.bib
	pandoc "$(INPUTDIR)"/*.md \
	"$(INPUTDIR)"/metadata.yml \
	-o "$(OUTPUTDIR)/thesis.tex" \
	-H "$(STYLEDIR)/preamble.tex" \
	-V fontsize=12pt \
	-V papersize=a4paper \
	-V documentclass:report \
	-N \
	--filter pandoc-shortcaption \
	--filter pandoc-crossref \
	--filter pandoc-citeproc \
	--bibliography="$(BIBFILE)" \
	--csl="$(STYLEDIR)/ref_format.csl"

docx:
	rm -f ./source/references.bib.bak
	sed -i.bak 's/phdthesis/masterthesis/' ./source/references.bib
	pandoc "$(INPUTDIR)"/*.md \
	"$(INPUTDIR)"/metadata.yml \
	-o "$(OUTPUTDIR)/thesis.docx" \
	--bibliography="$(BIBFILE)" \
	--filter pandoc-fignos \
	--csl="$(STYLEDIR)/ref_format.csl" \
	--toc

html:
	rm -f ./source/references.bib.bak
	sed -i.bak 's/phdthesis/masterthesis/' ./source/references.bib
	pandoc "$(INPUTDIR)"/*.md \
	"$(INPUTDIR)"/metadata.yml \
	-o "$(OUTPUTDIR)/thesis.html" \
	--standalone \
	--filter pandoc-fignos \
	--template="$(STYLEDIR)/template.html" \
	--bibliography="$(BIBFILE)" \
	--csl="$(STYLEDIR)/ref_format.csl" \
	--include-in-header="$(STYLEDIR)/style.css" \
	--toc \
	--number-sections
	rm -rf "$(OUTPUTDIR)/source"
	mkdir "$(OUTPUTDIR)/source"
	cp -r "$(INPUTDIR)/figures" "$(OUTPUTDIR)/source/figures"

.PHONY: help pdf docx html tex
