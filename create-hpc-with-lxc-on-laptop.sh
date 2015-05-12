#Create HPC Cluster With LXC
#Description: This script can be useful for creating HPC Cluster on the fly.
#It uses LXC,libvirt.
#Author : Sumit Joshi 
#Date : 01/05/2015
#
#
###Pre-Requisite for this script
#1)base.xml file
#2)Master node and compute node Filesystem 
#3)LXC template for master node and compue node




#################################MPI Master Node Creation#################################
path=/var/lib/lxc/master/rootfs

#creates master node filesystem in $path
lxc-create -t mpi-master -n master
echo "Master node filesystem created successfully"
echo ""

#preapre xml of container
cp base.xml master.xml
sed -i "s/NAME/master/" master.xml
sed -i "s<ROOT<$path<" master.xml

#Define xml for master node
virsh -c lxc:/// define master.xml
echo "Master node domain defined successfully"
echo ""

#start the container
virsh -c lxc:/// start master
echo "Container master started"
echo ""

#list current containers
virsh -c lxc:/// list --all
sleep 13

#Find IP of master node container - using master node filesystem
ip=$(tail -n15 $path/var/lib/dhcp/dhclient.eth0.leases | grep fixed-address | cut -d" " -f4 | cut -d";" -f1)
echo "IP of master node is $ip"
#Find the IP of container - using dnsmasq
#ip=$(cat $path/var/lib/libvirt/dnsmasq/default.leases | grep $2 |cut -d" " -f3)
#echo $ip


#Creating array which maintains list of host and IP address
nodes=();
nodes=("${nodes[@]}" "$ip" "master")
echo ${nodes[@]}


# file maintained in host os.
echo "$ip master" >> hosts


#######################################MPI Worker Node Creation ###################################

# No. of compute nodes you want to create
# Change it according your requirement
no=3

for ((i=1;i<=$no;i++))
do
	#echo "creating $compute-$i"
	host_name=compute-$i
	echo "Creating $host_name"
	echo ""

        path=/var/lib/lxc/$host_name/rootfs

	#create compute node filesystem
	lxc-create -t mpi-worker -n $host_name

        #preapre xml of container
	cp base.xml $host_name.xml
	sed -i "s/NAME/$host_name/" $host_name.xml
	sed -i "s<ROOT<$path<" $host_name.xml

        #Define xml for compute node
	virsh -c lxc:/// define $host_name.xml

	#List current containers
	virsh -c lxc:/// list --all
	sleep 13
	
	#Find IP of compute node	
	ip=$(tail -n15 $path/var/lib/dhcp/dhclient.eth0.leases | grep fixed-address | cut -d" " -f4 | cut -d";" -f1)
	echo "IP of $host_name is $ip"

	#Find the IP of container
        #ip=`cat /var/lib/libvirt/dnsmasq/default.leases | grep $2 |cut -d" " -f3`
        #echo $ip

	#This file will be created in base machine's home dir
	echo "$ip $host_name" >> hosts

	#Add ip and hostname to existing nodes array	
	nodes=("${nodes[@]}" "$ip" "$host_name")
	echo ${nodes[@]}
done

##Edit master and compute node filesystem for setting up /etc/hosts file
for ((i=1;i<=${#nodes[@]};i=i+2)) 
do
	path=/var/lib/lxc/${nodes[i]}/rootfs/
	echo "your for loop path is $path"
	cat hosts >> $path/etc/hosts
done
