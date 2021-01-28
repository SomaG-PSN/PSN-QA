#! /usr/bin/bash

exe=$1
filename=$2

for pdb in `cat $filename` 
do
   id=${pdb%.pdb}
   perl $exe/BIN/gen_mat_sid_eff.pl $pdb $id $exe $filename
   hb=`$exe/BIN/hbplus/hbplus $pdb | grep "hydrogen bonds found" | awk -F " " '{print $1}'`
   pdb_size=`perl $exe/BIN/pdb_size.pl $pdb`
   N_hb=`echo "scale=2; $hb/$pdb_size" | bc`
   echo "$id	$N_hb" >> network_params/hbplus.$filename.csv
   size=`wc -l $id.adjmat.0 | awk -F " " '{print $1}'`
   for submat in `ls $id\.submat*`
   do
     imin=${submat##*.}
     CC_lC=`$exe/BIN/a.exe -f $submat`
     N_CC_lC=`printf "%.2f" $(echo "scale=2; $CC_lC/$size" | bc)`
     echo "$id	$imin	$N_CC_lC" >> network_params/CC_LClu.$filename.csv  
   done
   rm $id\.submat*
   for cfinder in `ls -l $id\.cf* | grep -v ^d | awk -F " " '{print $8}'`
   do
     imin=${cfinder##*.}
     $exe/BIN/CFinder-2.0.5--1440/CFinder_commandline -i $cfinder -l $exe/BIN/CFinder-2.0.5--1440/licence.txt -k 3 > log 
     cd $cfinder\_files/k\=3/
     perl $exe/BIN/get_comm_sizes.pl size_distribution $size $imin $id $filename
     SLCom_k2=`perl $exe/BIN/common_node_comm.pl communities`
     N_SLCom_k2=`echo "scale=2; $SLCom_k2/$size" | bc`
     echo "$id	$imin	$N_SLCom_k2" >> ../../network_params/k-2_comm.$filename.csv
     cp ../graph ./
     perl $exe/BIN/extract_adj_mat.pl
     sub=`wc -l submat_Lcomm | awk -F " " '{print $1}'`
     CC_lcomm_NP1=""
     CC_lcomm=""
     if [[ $sub -gt 0 ]]; 
     then
       CC_lcomm=`$exe/BIN/a.exe -f submat_Lcomm`
       CC_lcomm_NP1=`printf "%.2f" $(echo "scale=2; $CC_lcomm/$size" | bc)`
     else
     CC_lcomm_NP1=0
     fi
     echo "$id	$imin	$CC_lcomm_NP1" >> ../../network_params/CC_k-2_comm.$filename.csv
     cd -
   done
   rm -rf $id.\cf*
   for mat in `ls $id\.adjmat*`
   do
     imin=${mat##*.}
     CC=`$exe/BIN/soffer.exe -f $mat`
     echo "$id	$imin	$CC" >> network_params/cc.$filename.csv
   done
   rm $id\.adjmat*
done
rm *.hb2 hbdebug.dat log
