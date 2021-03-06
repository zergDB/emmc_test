#!/usr/local/bin/perl 

use Getopt::Long qw(GetOptions);

GetOptions(
 # 'dir|d=s'  => \$strDir,
 'c=i' =>\$count,
 'testcase=s'  => \$testname,
 #'type=s'  => \$type,

);

if(!defined($count))
{
    $count = 1;
}

if(!defined($testname))
{
    die "please select testcase! For example: perl single_check_result.pl -testcase mnist -c 1\n";
}



if($count == 1){
$checkFile  =  "../../sw/build/apps/testANN/testANN_single/meminit_output_vector.txt";
}
if($count > 1){
$checkFile  =  "../../sw/build/apps/testANN/testANN_single_multi/meminit_output_vector.txt";
}
opendir(THISDIR, "../all_case_mif/") or die "serious dainbramage: $!";

@allfiles = grep { not /^\.{1,2}\z/} readdir THISDIR;

closedir THISDIR;


foreach (@allfiles){

#(-d "../all_case_mif/$testcase") &&	
	$testcase = $_;
	if( (-d "../all_case_mif/$testcase") && ($testcase =~ m/$testname/)){
	#	print "$testname\n";
			$stdFile    =  "../all_case_mif/$testcase/meminit_output_vectors.mif";
			#print "$stdFile\n";
		}
	}
open (STDFILE,$stdFile)||die "could not open file! $stdFile\n";
open (CFILE,$checkFile)||die "could not open file! $checkFile\n";



my $err_flag = 0;
my $line_num = 0;

 for ($i=0; $i < $count; $i++)
 {
 	while(defined($rsItem=<STDFILE>))
    {
    	$line_num = $line_num + 1;
    	   if(defined($crsItem = <CFILE>))  
    	   {
    	   	chomp($crsItem);  
    	   	chomp($rsItem);  
    	    if($rsItem ne $crsItem )
    	    {
    	    	 print "line number $line_num expect $rsItem  result $crsItem\n"; 
    	    	 $err_flag = 1;
    	    	}
    	   } else  {$err_flag = 1;}
    }   
 	}

if($err_flag)
{
	  print " fail\n";
	}  else  { print " ok\n";   }

close(STDFILE);
close(CFILE);

 