#!/usr/bin/perl
# This script takes a OOH rota in CVS format and transforms it into individual ics files, one for each doctor. 
# The format of the CSV file must be 
# - date in DD/MM/YYYY, weekday in short form, name of doctor, BH for Bank holiday or N for normal, each entry separated by a comma
# the output are a bunch of ical files for each doctor one . 
# The script is copyrighted by Peter von Kaehne and is published under the GPL version 2 or later
use strict;
use warnings;

sub main {
    if (scalar(@ARGV) < 1) {
        print "\nswap2ics.pl -- - provides ical files from a provided CSV file containing dates, day of week, names of two doctorr and info on shift pattern or else.\n";
        print "Syntax: swap2ics.pl csvfile [-d output-directory>]";
        print "- Arguments in braces < > are required. Arguments in brackets [ ] are optional.\n";
        print "- If no -d option is specified <STDOUT> is used.\n";
        exit (-1);
        }

    my $filename = $ARGV[0];
    my $nextarg = 1;
    my $outputDirectoryName ="./";
    
    if ($ARGV[$nextarg] eq "-d") {
        $outputDirectoryName = "$ARGV[$nextarg+1]";
        }
    
    

    open(INPUT, $filename) or die "Cannot open $filename";
    chomp(my @lines = <INPUT>);
    close INPUT;
            
    my @doctors = split(',',$lines[0]);
    
    my %shiftStart;
    my %shiftLength;
    
    my @shiftList = split(',',$lines[1]);
    
    foreach (@shiftList) {
        my @l = split(';',$_);
        
        $shiftStart{$l[0]} = $l[1];
        $shiftLength{$l[0]} = $l[2];
        }
    
    @lines = @lines[ 2 .. $#lines ]; 
    
    foreach (@doctors) {
        
        open(OUTF,">>",$outputDirectoryName."/".$_.".ics") or die "Cannot open outputfile";
        print OUTF "BEGIN:VCALENDAR\nVERSION:2.0\n";
                        
        foreach my $line (@lines) {
            
            
            my @line = split(',', $line);
            my $shiftPattern = $line[3];
            if ($_ eq $line[2]) {
                
                $line[1] =~s/^(\d{2})\/(\d{2})\/(\d{2})/$2\/$1\/$3/;
                my $startTime = `date -I'seconds' -d "$line[1] $shiftStart{$shiftPattern}" `;
                chomp($startTime);
                print OUTF "BEGIN:VEVENT\n";
                print OUTF "UID:$line[2]-".`date -I -d "$startTime"`;
                print OUTF "ORGANISER:XYZ\n";
                print OUTF "DTSTAMP:".`date "+%G%m%d"`;
                print OUTF "SUMMARY:OOH Shift\n";
                print OUTF "STATUS:CANCEL\n";
                print OUTF "DTSTART:".`date -d $startTime "+%Y%m%dT%H%M%S"`;
                print OUTF "DTEND:".`date -d "$startTime + $shiftLength{$shiftPattern} hours" "+%Y%m%dT%H%M%S"`;
                print OUTF "END:VEVENT\n";
                
                }
            }    

        foreach my $line (@lines) {
            
            
            my @line = split(',', $line);
            my $shiftPattern = $line[3];
            if ($_ eq $line[4]) {
                
                $line[1] =~s/^(\d{2})\/(\d{2})\/(\d{2})/$2\/$1\/$3/;
                my $startTime = `date -I'seconds' -d "$line[1] $shiftStart{$shiftPattern}" `;
                chomp($startTime);
                print OUTF "BEGIN:VEVENT\n";
                print OUTF "UID:$line[4]-".`date -I -d "$startTime"`;
                print OUTF "ORGANISER:XYZ\n";
                print OUTF "DTSTAMP:".`date "+%G%m%d"`;
                print OUTF "SUMMARY:OOH Shift\n";
                print OUTF "DTSTART:".`date -d $startTime "+%Y%m%dT%H%M%S"`;
                print OUTF "DTEND:".`date -d "$startTime + $shiftLength{$shiftPattern} hours" "+%Y%m%dT%H%M%S"`;
                print OUTF "DESCRIPTION:Reminder\n";
                print OUTF "BEGIN:VALARM\nACTION:DISPLAY\nDESCRIPTION:REMINDER\nTRIGGER:-PT24H\nEND:VALARM\n";
                print OUTF "END:VEVENT\n";
                
                }
            }    

        print OUTF "END:VCALENDAR\n";
        close(OUTF);        
        }
}

main();


