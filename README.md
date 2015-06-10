#Rapid HPC #

This script is used for rapidly creating HPC cluster using LXC on your laptop.

If you want to test some HPC code, than you can easily check that code with the help of RapidHPC.

##What we wiil do ?

We will be creating one master node and then 3 worker nodes to actually do the work.
Everthing will be installed automatically by script.

- Master Node:
  - Hostname : master
  - IP : 192.168.122.151 (IP may vary in your case, given by dnsmasq service)

- Compute Node 1:
  - Hostname : compute1
  - IP : 192.168.122.152

- Compute Node 2:
  - Hostname : compute2
  - IP : 192.168.122.153

- Compute Node 3:
  - Hostname : compute3
  - IP : 192.168.122.154



## So, How to Set it up?

Download the script :

    git clone https://github.com/joshisumit/rapid-hpc.git


Run the script:

     sudo bash rapid-hpc
     
     
##Verify your HPC Cluster Installation


    virsh -c lxc:/// list
    
You will get following output:

    Id    Name                           State
    ----------------------------------------------------
    5164  master                         running
    5166  compute-1                      running
    5169  compute-2                      running
    5199  compute-3                      running
 
 
###Verify Master container  
Login to your master node container with username 'ubuntu' and password 'ubuntu' :

    virsh -c lxc:/// console master

After logging in, Check following things in your master container:

1. `cluster` user: to operate our cluster.
2. NFS Server: to share cluster user's home directory with all compute nodes.Just check it by doing:

        cat /etc/exports
        
        /home/cluster *(rw,sync,no_subtree_check)
3. `/etc/hosts` file: entry for all compute nodes.
4. Passwordless SSH: cluster user will do password less SSH login in all compute node.
5. MPI (`mpich2`):MPI is installed, cluster will communicate with MPI.


###Verify compute container 
Login to your compute-1 node container with username 'ubuntu' and password 'ubuntu' :

    virsh -c lxc:/// console compute-1

After logging in, Check following things in your compute-1 container:

1. `/etc/fstab` file
2. Verify NFS share(/home/cluster) is properly mounted.If it is not mounted than mount it by running:
    mount -a
3. `/etc/hosts` file

##Summary

If you are working with HPC, having a full blown HPC Cluster on your laptop is awesome :)
