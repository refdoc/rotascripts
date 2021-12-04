#!/bin/sh

mkdir -p tmp
if [ -f $1 ]; then 
	./rotasplit.pl $1 -d tmp
	./rota2ics.pl $1 -d tmp 
	loffice --convert-to pdf --outdir tmp $1; 
	loffice --convert-to xlsx --outdir tmp $1;
	zip tmp/$1.zip tmp/*pdf tmp/*xlsx tmp/*ics tmp/*csv;
fi;
 