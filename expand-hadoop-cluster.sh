#!/bin/bash

# ******************************************************************* #
# This command will expand a hadoop cluster using the default 	      #
# xml file or the given file.                                         #
# e.g. expand-hadoop-cluster --handle cluster1 --cluster              #
# samples/xx.xml --hours 2   --nodes 3                                # 
# You need to specify a hadoop cluster handle in the --handle option  #
# ******************************************************************* #

BASEDIR="`dirname $0`/.."
HOURS=1
CONF="conf/sierra.conf"
hasmasterip="n"
hastemplate="n"

while(( "$#")); do
   if [ "--conf" == "$1" ]; then
   shift
   CONF=$1
    
  fi
  if [ "--cluster" == "$1" ]; then
  echo hasclustertemplate
   hastemplate="y"
   shift
   HADOOP_EXPAND_XML_TEMPLATE=$1
   echo HADOOP_EXPAND_XML_TEMPLATE $HADOOP_EXPAND_XML_TEMPLATE    
  fi
  
  if [ "--hours" == "$1" ]; then    
    shift 
    HOURS=$1
  fi
  if [ "--nodes" == "$1" ]; then  	
  	shift
  	NODES=$1
  	echo NODES $NODES
  	if [ $NODES == "0" ]; then
  		echo "must expand at least one slave node."
  		exit -1
  	fi
  fi
  if [ "--handle" == "$1" ];then
  	hasmasterip="y"
  	shift
  	HADOOP_CLUSTER_HANDLE=$1
  	echo HADOOP CLUSTER HANDLE $HADOOP_CLUSTER_HANDLE
  fi
  shift
done



#check is cluster handle is set in the command line 
if [ "X$hasmasterip" == "Xn" ];then
	echo "Usage: expand-hadoop-cluster --handle hadoop_cluster_handle --cluster hadoop_xml_file [--hours number_of_hours] --nodes number_of_nodes_to_add gqgq"
	exit -1
fi
if [ "X$hastemplate" == "Xn" ];then
	echo "Usage: expand-hadoop-cluster --handle hadoop_cluster_handle --cluster hadoop_xml_file [--hours number_of_hours] --nodes number_of_nodes_to_add"
	exit -1
fi
#get master ip address
  	MASTER_IP=`cat "$BASEDIR/Hadoop-Cluster/$HADOOP_CLUSTER_HANDLE/$HADOOP_CLUSTER_HANDLE-log/run-log.txt" | grep -o "[0-9][0-9]*.[0-9][0-9]*.[0-9][0-9]*.[0-9][0-9]*"|head -n 1 `
  	echo master ip  $MASTER_IP
#fix master ip address in xml file
HADOOP_EXPAND_XML="$BASEDIR/Hadoop-Cluster/$HADOOP_CLUSTER_HANDLE/expand_$HADOOP_CLUSTER_HANDLE.xml"
cp $HADOOP_EXPAND_XML_TEMPLATE $HADOOP_EXPAND_XML
sed -i "s/MASTERIP/$MASTER_IP/" $HADOOP_EXPAND_XML
#set the number of nodes added in the xml file
sed -i "s/NumberOfNodes/$NODES/" $HADOOP_EXPAND_XML


#Launch the hadoop cluster
$BASEDIR/bin/cloud-client.sh --run --cluster $HADOOP_EXPAND_XML --hours $HOURS --conf $CONF 



