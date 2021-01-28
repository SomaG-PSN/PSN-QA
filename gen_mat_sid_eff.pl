#! /usr/bin/perl

use List::Util qw( min max );
use List::Util qw( first );
# Program to make adjacency matrix representation of Protein Side chain Interaction Graph
# perl gen_adj.pl clean.pdb

$id = $ARGV[1];
chomp($id);
$f= $ARGV[3];
chomp($f);

open(Read1,$ARGV[0])or die("can not open pdb.inp as: $!\n");
@hold_pdb=<Read1>;
close(Read1);

$nc_name = "ncov.".$f.".csv";
$sl_name = "SLCLu.".$f.".csv";
open(nc,">>network_params/$nc_name");
open(sl,">>network_params/$sl_name");

$Norm_value{ALA}=55.75;
$Norm_value{ARG}=93.78;
$Norm_value{ASN}=73.40;
$Norm_value{ASP}=75.15;
$Norm_value{CYS}=54.95;
$Norm_value{CYF}=54.95;
$Norm_value{GLN}=78.13;
$Norm_value{GLC}=78.13;
$Norm_value{GLU}=78.82;
$Norm_value{GLF}=78.82;
$Norm_value{GLM}=78.82;
$Norm_value{GLT}=78.82;
$Norm_value{GLY}=47.31;
$Norm_value{HIS}=83.73;
$Norm_value{HIF}=83.73;
$Norm_value{HIM}=83.73;
$Norm_value{HIT}=83.73;
$Norm_value{ILE}=67.94;
$Norm_value{LEU}=72.25;
$Norm_value{LYS}=69.60;
$Norm_value{MET}=69.25;
$Norm_value{MEF}=69.25;
$Norm_value{PHE}=93.30;
$Norm_value{PRO}=51.33;
$Norm_value{SER}=61.39;
$Norm_value{THR}=63.70;
$Norm_value{TRP}=106.70;
$Norm_value{TYR}=100.71;
$Norm_value{VAL}=62.36;

%hash;
$Totaa_no =0;
#Extract side chain atomic coordinates and take main chain for Glycine
foreach $line(@hold_pdb)
{
        $line=~s/\n//;
        @temp = split(/\s+/,$line);
	$amino_name= $temp[3];
        $atom_type= $temp[2];
        $atom_type=~s/\s//gi;
        if($atom_type eq 'CA')
        {
          $Totaa_no++;
        }
        if(($amino_name eq 'GLY')&&($atom_type eq 'CA'))
        {
	    push(@Sidechain,$line);
            $val=$temp[3];
            $key=$temp[4];
            $hash{$key}=$val;
        }
        else
        { 
            if(($atom_type ne 'CA')&&($atom_type ne 'N')&&($atom_type ne 'O')&&($atom_type ne 'C')&&($atom_type ne 'FE')&&($atom_type !~ /^H/)&&($amino_name ne 'MOH'))
            {
                push(@Sidechain,$line);
                $val=$temp[3];
                $key=$temp[4];
                $hash{$key}=$val;
            }
        }
}

#Put atomic cordinates in a 2D array for easy access
foreach $line(@Sidechain)
{
        $resno = substr($line,23,3);
	$resno=~s/\s//;
	for($i=1;$i<=$Totaa_no;$i++)
	{
		if($i==$resno)#Atoms of one amino acid are put in different columns of same row
		{
			push(@{$dd_side[$i-1]},$line);
		}
		last if($i>$resno);
	}
}
for($i=0;$i<$Totaa_no;$i++)
{
	for($j=0;$j<$Totaa_no;$j++)
	{
                $int_mat[$i][$j]=0;
	}
}

#Interaction calculation
for($i=0;$i<$Totaa_no;$i++)
{					
	for($j=$i+2;$j<$Totaa_no;$j++)#These 2 loops compare each residue pair
	{
			$interacting_pair=0;
			$total_dist=0;
			foreach $m(@{$dd_side[$i]})
			{
                            $x1=substr($m,31,7);
                            $x1 =~ s/\s//;
                            $y1=substr($m,39,7);
                            $y1 =~ s/\s//;
                            $z1=substr($m,47,7);
                            $z1 =~ s/\s//;
			    foreach $n(@{$dd_side[$j]})#These 2 loops compare each side chain atom pair
			    {
				$x2=substr($n,31,7);
                                $x2 =~ s/\s//;
				$y2=substr($n,39,7);
                                $y2 =~ s/\s//;
				$z2=substr($n,47,7);
                                $z2 =~ s/\s//;

				$dist=sqrt((($x2-$x1)**2)+(($y2-$y1)**2)+(($z2-$z1)**2));
				if($dist>1.7 && $dist<=4.5)
				{
				    $interacting_pair++;
				    $total_dist=$total_dist+$dist;
				}
			        if($interacting_pair>0)
			        {
				  $res_i=substr($m,17,3);
				  $res_j=substr($n,17,3);
                                  $res_no_i = $i+1;
                                  $res_no_j = $j+1;
				  foreach(keys %Norm_value)
				  {
					if($res_i eq $_)
					{
						$Norm_i=$Norm_value{$_};
					}
					if($res_j eq $_)
					{
						$Norm_j=$Norm_value{$_};
					}
				 }
			         $Norm=sqrt($Norm_i*$Norm_j);
                                 if($Norm!=0)#Perl takes division by zero as illegal
                                 {
			        	$Interaction=($interacting_pair/$Norm)*100;
                                        $int_mat[$i][$j]=$Interaction;
                                        $int_mat[$j][$i]=$Interaction;
			         }
		               }    
	                    }
                        }
                  }
         }

#Put matrices in files

for($imin=0;$imin<8;$imin++)
{
  $mat = $id.".adjmat.".$imin;
  $cf = $id.".cf_input.".$imin;
  open(adj, ">$mat");
  open(fin,">$cf");
  undef @adjmat;
  $ncov = 0;
  for($i=0;$i<$Totaa_no;$i++)
  {
	for($j=0;$j<$Totaa_no;$j++)
	{
                if($int_mat[$i][$j] > $imin)
                {
		  $adjmat[$i][$j] = 1;
                  print adj "$adjmat[$i][$j]\t";
                  print fin "$i\t$j\n";
                  $ncov++;
                }
                else
                {
                  $adjmat[$i][$j] = 0;
                  print adj "$adjmat[$i][$j]\t";
                }
	}
        print adj "\n";
   }
   close adj;
   close fin;
   # get ncov
   $norm_ncov = $ncov/(2*$Totaa_no);
   print nc "$id\t$imin\t$norm_ncov\n";
   # get SLClu
   $slcl = &dfs(\@adjmat,$Totaa_no,$imin,$id);
   print sl "$id\t$imin\t$slcl\n";
}

close nc;
close sl;

sub dfs
{
   undef @test;
   my($param,$size,$im,$I)=@_;
   my @matrix = @{$param};
   my @cluster;
   my $ind = 0;
   my @nodes= (0..$#matrix);
   my $clno = 1;
   while (@nodes)
   {
     my @stack=();
     unshift @stack, shift @nodes;
     while (@stack)
     {
       my @tmp;
       my @newnodes;
       my $ind = $stack[0];
       foreach my $jnd (@nodes)
       {
         if (0 + $matrix[$ind][$jnd])
         {
           push @tmp, $jnd;
         }
         else
         {
           push @newnodes, $jnd;
         }
       }
       if (@nodes == @newnodes)
       {
         my $p = shift @stack;
         push @{$cluster[$clno]}, $p;
         my $y = $p+1;
         @newnodes = ();
        }
        else
        {
          if (@tmp)
          {
            unshift @stack, shift @tmp;
            push @newnodes, @tmp;
            @tmp = ();
          }
          @nodes = @newnodes;
          @newnodes = ();
        }
     }
     $num = scalar @{$cluster[$clno]};
     push(@test,$num);
     $clno++;
   }
    my $max = max @test;
    $SLCL = $max/$size;
    my $index = first { $test[$_] eq $max } 0..$#test;
    $name = $I.".submat_LC.".$im;
    open(fw,">$name");
    foreach my $ind (sort { $a <=> $b } @{$cluster[$index+1]}) 
    {
      foreach my $jnd (sort { $a <=> $b} @{$cluster[$index+1]}) 
      {
         print fw "$matrix[$ind][$jnd]\t";
      }
      print fw "\n";
    }
    close fw;
    return $SLCL;
}
