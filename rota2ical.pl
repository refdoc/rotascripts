#!/usr/bin/perl
# This script takes a OOH rota in CVS format and transforms it into individual ical files, one for each doctor. 
# The format of the CSV file must be 
# - date in DD/MM/YYYY, weekday in short form, name of doctor, BH for Bank holiday or N for normal, each entry separated by a comma
# the output are a bunch of ical files for each doctor one . 
# The script is copyrighted by Peter von Kaehne and is published under the GPL version 2 or later
#use strict;
#use warnings;

sub main {
    if (scalar(@ARGV) < 1) {
        print "\nrota2ical.pl -- - provides ical files from a provided CSV file containing dates, day of week, name of doctor and info on BH or else.\n";
        print "Syntax: rota2ical.pl csvfile [-d output-directory>]";
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
    
    my $shiftList = <INPUT>;
    my %shiftStart;
    my %shiftLength;
    
    chomp($shiftList);
    my @shiftList = split(',',$shiftList);
    
    print "Shift Patterns:\n";
    foreach (@shiftList){
        print $_."\n";
        }
    
    foreach (@shiftList) {
        my @l = split(';',$_);
        foreach (@l) {
            print $_."\n";
            }
        
        $shiftStart{$l[0]} = $l[1];
        $shiftLength{$l[0]} = $l[2];
        }
    
    close INPUT;
    
    foreach (@doctors) {
        open(INPUT, $filename) or die "Cannot open $filename";
        my $line = <INPUT>; # read and drop first line with doctors' list
        $line=<INPUT>;#drop next one too with shift patterns
        
        open(OUTF1,">>",$outputDirectoryName."/".$_.".csv") or die "Cannot open outputfile";
        open(OUTF2,">>",$outputDirectoryName."/".$_.".ics") or die "Cannot open outputfile";
        print OUTF2 "BEGIN:VCALENDAR\nVERSION:2.0\n";
                        
        while($line = <INPUT>)
            {
            chomp($line);
            my @line = split(',', $line);
            my $shiftPattern = $line[3];
            if ($_ eq @line[2]) {
                print OUTF1 $line;
                
                $line[1] =~s/^(\d{2})\/(\d{2})\/(\d{2})/$2\/$1\/$3/;
                my $startTime = `date -I'seconds' -d "$line[1] $shiftStart{$shiftPattern}" `;
                chomp($startTime);
                
                print OUTF2 "BEGIN:VEVENT\nUID:$line[2]\n";
                print OUTF2 "DTSTAMP:".`date "+%G%m%d"`;
                print OUTF2 "SUMMARY:OOH Shift\n";
                print OUTF2 "DTSTART:".`date -d $startTime "+%Y%m%dT%H%M%S"`;
                print OUTF2 "DTEND:".`date -d "$startTime + $shiftLength{$shiftPattern} hours" "+%Y%m%dT%H%M%S"`;
                print OUTF2 "DESCRIPTION:Reminder\n";
                print OUTF2 "BEGIN:VALARM\nACTION:DISPLAY\nDESCRIPTION:REMINDER\nTRIGGER:-PT24H\nEND:VALARM\n";
                print OUTF2 "END:VEVENT\n";
                
                }
            }    
        close(INPUT);
        close(OUTF1);
        print OUTF2 "END:VCALENDAR\n";
        close(OUTF2);        
        }
}

main();


