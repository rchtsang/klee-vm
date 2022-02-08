#!/usr/bin/env bash

##################################################
# Vagrant Ubuntu 20.04 STP Installation Script
# 	
# Description:
# 	Provisions Ubuntu 20.04 VM with STP for KLEE
# 	Assumes /vagrant as mountpoint
# 	from https://klee.github.io/build-stp/
##################################################

CWD=$(realpath .)

APT_INSTALL_PACKAGES=(
	cmake
	bison
	flex
	libboost-all-dev
	python
	perl
	zlib1g-dev
	minisat
)

# install new packages
echo "installing packages: ${APT_INSTALL_PACKAGES[@]}"
sudo apt-get install --force-yes -y "${APT_INSTALL_PACKAGES[@]}"
echo "finished installing apt packages!"

# install STP from source
cd /vagrant
git clone https://github.com/stp/stp.git
cd stp 
git checkout tags/2.3.3
mkdir build && cd build
if cmake -DCMAKE_INSTALL_PREFIX=/usr/local/ .. && make && sudo make install ; then
	echo -e "successfully built stp!\n"
	if ! grep -q "ulimit -s unlimited" /home/vagrant/.bashrc ; then 
    	echo -e "\nulimit -s unlimited\n" >> /home/vagrant/.bashrc 
	fi
	# add library path to ldconfig (requires root)
	# if ! sudo grep -q "/usr/local/lib" /etc/ld.so.conf ; then
	# 	sudo echo "/usr/local/lib" >> /etc/ld.so.conf 
	# 	sudo ldconfig
	# fi
	# if no root privilege 
	if ! grep -q "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" /home/vagrant/.bashrc ; then
		echo -e "\nexport LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH\n" >> /home/vagrant/.bashrc
	fi
else
	echo -e "build failed!\n\n"
fi
cd $CWD