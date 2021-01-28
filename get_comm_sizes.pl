#! /usr/bin/perl
# (c) Saraswathi Vishveshwara, India
# code to get sizes of the communities from size_distribution file

open(fr,$ARGV[0]);
@data = <fr>;
close fr;

$size = $ARGV[1];
chomp($size);

$imin = $ARGV[2];
chomp($imin);

$id = $ARGV[3];
chomp($id);

$list = $ARGV[4];
chomp($list);

$t1 = "top1_k-1_comm.".$list.".csv";
$t2 = "top2_k-1_comm.".$list.".csv";
$t3 = "top3_k-1_comm.".$list.".csv";

open(fw1,">>../../network_params/$t1");
open(fw2,">>../../network_params/$t2");
open(fw3,">>../../network_params/$t3");

$index=0;
%comm_size;
foreach $line(@data)
{
  $line =~ s/\n//;
  if($line =~ /^\d+/)
  {
    @temp = split(/\s+/,$line);
    for($i=0;$i<$temp[1];$i++)
    {
      $index++;
      $comm_size{$index} = $temp[0];
    }
  }
}

@all_size = sort{$b<=>$a}values %comm_size;
$top2 = $all_size[0]+$all_size[1];
$top3 = $top2 + $all_size[2];

$one=$all_size[0]/$size;
$two=$top2/$size;
$three=$top3/$size;

printf fw1 "%s\t%d\t%.2f\n", $id, $imin, $one;
printf fw2 "%s\t%d\t%.2f\n",$id,$imin,$two;
printf fw3 "%s\t%d\t%.2f\n",$id,$imin,$three;

close fw1;
close fw2;
close fw3;
