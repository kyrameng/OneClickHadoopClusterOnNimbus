#!/bin/bash

# ***************************************************************************#
# This command will launch a hadoop cluster using the default 	             #
# xml file or the given file.                                                #
# e.g. launch-hadoop-cluster --cluster samples/xx.xml --hours 2  --nodes 3   #
#			     --conf sierra.conf				     #	
# ************************************************************************** #

#BASEDIR="`dirname $0`/.."
BASEDIR="$(dirname $0)/.."
pushd $BASEDIR > /dev/null 2>&1
BASEDIR=$(pwd)
echo $BASEDIR
#HADOOP_XML_TEMPLATE="$BASEDIR/samples/hadoop-cluster-template.xml"
HADOOPDIR="$BASEDIR/Hadoop-Cluster"
if [ ! -d "$HADOOPDIR" ]; then
  mkdir $HADOOPDIR
fi

COUNTER=98
HOURS=1
CONF="conf/sierra.conf"
NODES=2 #This implies the number of slave nodes. Master node will be counted seperately.
USAGE="Usage: launch-hadoop-cluster --cluster template.xml [--nodes 3] [--hours 2]"



hastemplate="n"
while(( "$#")); do
  if [ "--cluster" == "$1" ]; then
   hastemplate="y"
   shift
   HADOOP_XML_TEMPLATE=$1
    
  fi
  if [ "--conf" == "$1" ]; then
   shift
   CONF=$1
    
  fi
  if [ "--hours" == "$1" ]; then
    
    shift 
    HOURS=$1
  fi
  if [ "--nodes" == "$1" ]; then
  	
  	shift
  	NODES=$1
  	if [ $NODES == "0" ]; then
  		echo "must have at least one slave node."
  		exit -1
  	fi
  fi
  shift
done

if [ "X$hastemplate" == "Xn" ]; then
	echo "must provide a cluster template file using the --cluster option."
	exit -1
fi

#create a directory for storing logs and the custormized xml file of this cluster.
COUNTER=$((COUNTER+1))
DIR="$HADOOPDIR/cluster$COUNTER"
HADOOP_CLUSTER_HANDLE="cluster$COUNTER"
mkdir $DIR
sed -i "s/COUNTER=[0-9][0-9]*/COUNTER=$COUNTER/" $BASEDIR/bin/launch-hadoop-cluster.sh

HADOOP_XML_FILE="$DIR/cluster$COUNTER.xml"
cp $HADOOP_XML_TEMPLATE $HADOOP_XML_FILE
sed -i "s/NumberOfNodes/$NODES/" $HADOOP_XML_FILE




#Launch the hadoop cluster
tempfile="$RANDOM"

$BASEDIR/bin/cloud-client.sh --run  --cluster $HADOOP_XML_FILE  --hours $HOURS --conf $CONF |tee $tempfile

CLUSTER_HANDLE=`cat $tempfile|grep -o "cluster-[0-9][0-9]*" | head -n 1`
echo $CLUSTER_HANDLE

rm $tempfile
sleep 2s #is this necessary?

#create a symbolic link to the corresponding cluster directory

ln -s "$BASEDIR/history/$CLUSTER_HANDLE" "$BASEDIR/Hadoop-Cluster/$HADOOP_CLUSTER_HANDLE/$HADOOP_CLUSTER_HANDLE-log"

popd > /dev/null 2>&1

echo "Hadoop-Cluster-Handle cluster$COUNTER"

 


