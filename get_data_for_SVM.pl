#! /usr/bin/perl
# (c) Saraswathi Vishveshwara
# code to get data from csv file in SVM formatting

$list = $ARGV[0];
chomp($list);

$nc = "ncov.".$list.".csv";
open(fr,$nc);
@ncov = <fr>;
close fr;

$sl = "SLCLu.".$list.".csv";
open(fr1,$sl);
@lclu = <fr1>;
close fr1;

$k2 = "k-2_comm.".$list.".csv";
open(fr2,$k2);
@k_2_comm = <fr2>;
close fr2;

$t1 = "top1_k-1_comm.".$list.".csv";
open(fr3,$t1);
@top1 = <fr3>;
close fr3;

$t2 = "top2_k-1_comm.".$list.".csv";
open(fr4,$t2);
@top2 = <fr4>;
close fr4;

$t3 = "top3_k-1_comm.".$list.".csv";
open(fr5,$t3);
@top3 = <fr5>;
close fr5;

$cc_n = "cc.".$list.".csv";
open(fr6,$cc_n);
@cc = <fr6>;
close fr6;

$Ccomm = "CC_k-2_comm.".$list.".csv";
open(fr7,$Ccomm);
@cc_comm = <fr7>;
close fr7;

$Clcl = "CC_LClu.".$list.".csv";
open(fr8,$Clcl);
@cc_lc = <fr8>;
close fr8;

$hb = "hbplus.".$list.".csv";
open(fr9,$hb);
@hb = <fr9>;
close fr9;

$name = "model_id.".$list;
open(fw,">$name");
%hash;

&get_type1_param(\@ncov,0,7);
&get_type1_param(\@lclu,15,22);
&get_type1_param(\@k_2_comm,30,37);
&get_type2_param(\@top1,45);
&get_type2_param(\@top2,53);
&get_type2_param(\@top3,61);
&get_type2_param(\@cc,69);
&get_type2_param(\@cc_comm,77);
&get_type2_param(\@cc_lc,85);
&get_hb(\@hb,93);

sub get_type1_param
{
   my($param,$index,$index1)=@_;
   for($i=0;$i<scalar(@{$param});$i++)
   {  
      ${$param}[$i] =~ s/\n//;
      @temp = split(/\s+/,${$param}[$i]);
      for($imin=0;$imin<8;$imin++)
      {
         if($temp[1] eq $imin)
         {
            ${$hash{$temp[0]}}[$imin+$index]=$temp[2];
            if($imin > 0)
            {
               ${$hash{$temp[0]}}[$imin+$index1] = ${$hash{$temp[0]}}[$imin+$index-1] - ${$hash{$temp[0]}}[$imin+$index];
            }
          last;
         }
      }
   }
}

sub get_type2_param
{
   my($param,$index)=@_;
   for($i=0;$i<scalar(@{$param});$i++)
   {
      ${$param}[$i] =~ s/\n//;
      @temp = split(/\s+/,${$param}[$i]);
      for($imin=0;$imin<8;$imin++)
      {
         if($temp[1] eq $imin)
         {
            ${$hash{$temp[0]}}[$imin+$index]=$temp[2];
            last;
         }
      }
   }
}

sub get_hb
{
   my($param,$index)=@_;
   for($i=0;$i<scalar(@{$param});$i++)
   {
      ${$param}[$i] =~ s/\n//;
      @temp = split(/\s+/,${$param}[$i]);
      ${$hash{$temp[0]}}[$index]=$temp[1];
   }
}
## writing in libSVM format

foreach $key(sort {$a<=>$b} keys %hash)
{
  $count=1;
  print fw "$key\n";
  printf "%d\t",-1;
  foreach $ele(@{$hash{$key}})
  {
    if($ele eq " ")
    {
       $ele = 0;
    }
    printf "%d:",$count;
    printf "%1.6f\t",$ele;
    $count++;
  }
  printf "\n";
}

close fw;
