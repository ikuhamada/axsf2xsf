#!/bin/sh
#
# A script to split AXSF file into indivisual XSF files
# Written by Ikutaro Hamada
#
if [ $# -eq 0 ];
then
  echo 'No arguments.'
  exit
fi

input=$@

prefix=${input%%.axsf}

nline=`wc -l ${input} | awk '{print $1}'`

nstep=`grep ANIMSTEP $input | awk '{print $2}'`

ntmp=`grep -n PRIMCOORD $input | head -1 | awk -F\: '{print $1}'`

if [ -z ${ntmp} ];
then

# --- ATOMS ---

nline2=`expr ${nline} - 1`
tail -${nline2} $input > TAIL
nline_coord=`expr ${nline2} / ${nstep}`

split -l ${nline_coord} TAIL TMP_
n=0
for f in TMP_*
do
n=`expr ${n} + 1`
nn=`printf "%3.3d\n" ${n}`
echo Generating ${prefix}'_#'${nn}'.xsf'
cat ${f} > ${prefix}'_#'${nn}'.xsf'
done

rm -f TAIL TMP_*

else

# --- CRYSTAL ---

ntmp1=`expr ${ntmp} - 1`
ntmp2=`expr ${ntmp1} - 1`
nline2=`expr ${nline} - ${ntmp1}`
nline_coord=`expr ${nline2} / ${nstep}`

head -${ntmp1} $input | tail -${ntmp2} > HEADER
tail -${nline2} $input > TAIL
split -l ${nline_coord} TAIL TMP_
n=0
for f in TMP_*
do
n=`expr ${n} + 1`
nn=`printf "%3.3d\n" ${n}`
echo Generating ${prefix}'_#'${nn}'.xsf'
cat HEADER ${f} > ${prefix}'_#'${nn}'.xsf'
done

rm -f HEADER TAIL TMP_*

fi


