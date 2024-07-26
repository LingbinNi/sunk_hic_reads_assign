#!/usr/bin/perl -w 
#written by Lingbin

# read file
my %hash1;
open (FH,"/net/eichler/vol28/projects/hgsvc/nobackups/hic_hgsvc/12.MrsFastSUNK/03.sam_merge/merge.sam")|| die "can not open the file merge.sam\n";
while(<FH>){
    chomp;
    my @line = split("\t");
    my @split_array = split(/_/,$line[0]);
    my $pos = join("_",$split_array[0],$split_array[1],$split_array[2]);
    push @{$hash1{$line[2]}},$pos;
    }
close(FH);

# read assign
my %hash2;
foreach my $key (sort keys %hash1){
	my %count;
	$count{$_}++ for @{$hash1{$key}};
	my @max_key = sort { $count{$b} <=> $count{$a} } keys %count;
	$hash2{$key} = $max_key[0];
}

# remove unique
my %hash3;
foreach my $key (sort keys %hash2){
	my $key2 = $key;
	if ($key2 =~ -1){
	$key2 =~ s/-1/-2/;
	}
	else{
	$key2 =~ s/-2/-1/;
	}
	if (exists $hash2{$key2}){
	$hash3{$key} = $hash2{$key};
	$hash3{$key2} = $hash2{$key2};
	}
}

# read replace
my %hash4;
open (FH,"/net/eichler/vol28/projects/hgsvc/nobackups/hic_hgsvc/07.HiCProMappingParameter/parameter-bowtie-L-Full/output/hic_results/matrix/HG00733/raw/10000/HG00733_10000_abs.bed")|| die "can not open the file HG00733_10000_abs.bed\n";
while(<FH>){
    chomp;
    my @split_array = split("\t");
    my $pos = join("_",$split_array[0],$split_array[1],$split_array[2]);
    $hash4{$pos}=$split_array[3];
    }
close(FH);

# read pair
my %hash5;
foreach my $key (sort keys %hash3){
	if ($key =~ -1){
	$key2 = $key;
	$key2 =~ s/-1/-2/;
	$pos1 = $hash3{$key};
	$pos2 = $hash3{$key2};
	$num1 = $hash4{$pos1};
	$num2 = $hash4{$pos2};
	if ($num1 <= $num2){
	push @{$hash5{$num1}{$num2}},$key;
	}
	else{
	push @{$hash5{$num2}{$num1}},$key;
	}
	}
}

# pair count
foreach my $key1 (sort keys %hash5){
	foreach my $key2 (sort keys  %{$hash5{$key1}}){
	my $length = scalar @{$hash5{$key1}{$key2}};
	print "$key1\t$key2\t$length\n";
	}
}
