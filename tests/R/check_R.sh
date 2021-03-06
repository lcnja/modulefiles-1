#!/bin/bash

hostname=`hostname -f`
cur_time=`date`
echo "Hostname $hostname"
echo "Time: $cur_time"
echo "OSG Site: $OSG_SITE_NAME"
echo "GWMS Entry Name: $GLIDEIN_Entry_Name"
echo "GWMS Resource Name: $GLIDEIN_ResourceName"


source /cvmfs/oasis.opensciencegrid.org/osg/modules/lmod/5.6.2/init/bash
module load R/3.1.1
cd input_files
Rscript test.Rscript > nlm.out
output=`diff -u -w -B nlm.test nlm.out`

if [ "$output" != "" ];
then
  echo "Error! Difference in outputs:"
  echo $output
  exit 1
fi

