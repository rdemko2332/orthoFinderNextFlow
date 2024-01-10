#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($result,$groupsFile,$output,$allBlast);

&GetOptions("result=s"=> \$result, # Sorted diamond similarity results
	    "groupsFile=s"=> \$groupsFile,
            "output=s"=> \$output,
            "allBlast" => \$allBlast);

my %coreSeqToGroup;

if ($allBlast) {
    open(my $groups, '<', $groupsFile) || die "Could not open file $groupsFile: $!";

    while (my $line = <$groups>) {
        chomp $line;
        if ($line =~ /^(OG\d+_\d+):\s(.*)/) {
            my $groupId = $1;
	    my $seqString = $2;
	    my @seqs = split(/\s/, $seqString);
	    foreach my $seq (@seqs) {
                $coreSeqToGroup{$seq} = $groupId;
	    }
        }
        else {
            die "Improper group file format\n";
        }
    }
}
    
open(my $data, '<', $result) || die "Could not open file $result: $!";
open(OUT,">$output");

my %seqToGroup;

# for each pair wise result
while (my $line = <$data>) {
    chomp $line;

    # Retrieve the values
    my @lineAr = split(/\t/, $line);

    # Retrieve the qseq, seq (best reps are identified by the group they represent) and the evalue
    my $qseq = $lineAr[0];
    my $sseq = $lineAr[1];
    my $evalue = $lineAr[10];

    # If first result for this sequence
    unless($seqToGroup{$qseq}) {
	my $group;
	if ($allBlast)  {
	    $group = $coreSeqToGroup{$sseq};
	}
	else {
            $group = $sseq;
	}
	# Set the sequences group and e-value
        $seqToGroup{$qseq}->{evalue} = $evalue;
        $seqToGroup{$qseq}->{group} = $group;
    }

    # If we found a better match
    if($seqToGroup{$qseq}->{evalue} > $evalue) {
	my $group;
	if ($allBlast)  {
	    $group = $coreSeqToGroup{$sseq};
	}
	else {
            $group = $sseq;
	}
	# Set the new evalue and group
        $seqToGroup{$qseq}->{evalue} = $evalue;
        $seqToGroup{$qseq}->{group} = $group;
    }

}

# For each sequence, print out it's group assignment
foreach my $seq (keys %seqToGroup) {
    print OUT "$seq\t" . $seqToGroup{$seq}->{group} . "\n";
}
