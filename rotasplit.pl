#!/usr/bin/perl
# This script takes a OOH rota in CVS format and transforms it into individual ics files, one for each doctor. 
# The format of the CSV file must be 
# - date in DD/MM/YYYY, weekday in short form, name of doctor, BH for Bank holiday or N for normal, each entry separated by a comma
# the output are a bunch of ical files for each doctor one . 
# The script is copyrighted by Peter von Kaehne and is published under the GPL version 2 or later
#use strict;
#use warnings;

sub main {
    if (scalar(@ARGV) < 1) {
        print "\nrotasplit.pl -- - provides individual cvs files from a provided CSV file containing dates, day of week, name of staff and info on shiftpattern or else.\n";
        print "Syntax: rotasplit.pl csvfile [-d output-directory>]";
        print "- Arguments in braces < > are required. Arguments in brackets [ ] are optional.\n";
        print "- If no -d option is specified <STDOUT> is used.\n";
        exit (-1);
        }

    my $filename = $ARGV[0];
    my $nextarg = 1;
    my $outputDirectoryName ="./";
    
    if ($ARGV[$nextarg] eq "-d") {
        $outputDirectoryName = "$ARGV[$nextarg+1]";
        $nextarg += 2;
        }
    
    

    open(INPUT, $filename) or die "Cannot open $filename";
    
    my $doctorsList = <INPUT>;
    chomp($doctorsList);    
    my @doctors = split(',',$doctorsList);
    
    foreach (@doctors) {
        $line = <INPUT>;
        print OUTF $line;
        while($line = <INPUT>)
            {
            my @line = split(',', $line);
            if ($_ eq @line[2]) {
                print OUTF $line;
                }
            }    
        close(INPUT);
        close(OUTF);
        }
}

main();


