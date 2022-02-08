#!/usr/bin/env bash

##################################################
# Vagrant Ubuntu 20.04 Provisioning Script 
# 	
# Description:
# 	Provisions Ubuntu 20.04 VM with deps for KLEE
# 	Assumes /vagrant as mountpoint
# 	refer to https://klee.github.io/build-llvm9/
##################################################

# CWD=$(realpath .)

APT_INSTALL_PACKAGES=(
	coreutils
	build-essential 
	curl
	libcap-dev
	git 
	cmake 
	libncurses5-dev 
	unzip 
	libtcmalloc-minimal4 
	libgoogle-perftools-dev 
	libsqlite3-dev 
	doxygen
	python3
	python3-pip
	gcc-multilib
	g++-multilib
	clang-9 
	llvm-9 
	llvm-9-dev 
	llvm-9-tools
)

PIP_INSTALL_PACKAGES=(
	lit 
	tabulate 
	wllvm
)

# update list of available packages
echo "updating apt-get..."
sudo apt-get update -y

# upgrade installed packages
echo "upgrading installed packages..."
sudo apt-get upgrade -y

# install new packages
echo "installing packages: ${APT_INSTALL_PACKAGES[@]}"
sudo apt-get install --force-yes -y "${APT_INSTALL_PACKAGES[@]}"
echo "finished installing apt packages!"

# install pip packages
echo "installing packages: ${PIP_INSTALL_PACKAGES[@]}"
sudo pip install "${PIP_INSTALL_PACKAGES[@]}"
echo "finished installing pip packages!"

# symlink clang and llvm
LLVM_BINS=/usr/bin/llvm-*
CLANG_BINS=/usr/bin/clang*
LLC_BIN=/usr/bin/llc-9
OPT_BIN=/usr/bin/opt-9
for fname in $LLVM_BINS $CLANG_BINS $LLC_BIN $OPT_BIN ; do
	link=/usr/local/bin/$(basename ${fname::-2})
	echo "linking" $fname "to" $link
	sudo ln -s $fname $link
done

# install STP
echo "installing stp"
sudo chmod +x /vagrant/scripts/provision-stp.sh
/vagrant/scripts/provision-stp.sh
source /home/vagrant/.bashrc

# install klee from source
cd /vagrant
PREV_DIR=$(realpath .)
git clone https://github.com/klee/klee.git
cd klee
if mkdir build && cd build ; then
	curl -OL https://github.com/google/googletest/archive/release-1.11.0.zip
	unzip release-1.11.0.zip
	echo "building and testing klee..."
	if cmake \
		-DENABLE_SOLVER_STP=ON \
		-DENABLE_UNIT_TESTS=ON \
		-DGTEST_SRC_DIR=$PREV_DIR/klee/build/googletest-release-1.11.0/ \
		.. \
		&& make \
		&& echo "successfully built klee!" ; then
			for fname in $(realpath bin/*) ; do
				link=/usr/local/bin/$(basename $fname)
				echo "linking" $fname "to" $link
				sudo ln -s $fname $link
			done
			make systemtests
			make unittests
	fi
fi
cd $PREV_DIR

# login to /vagrant folder on ssh
if ! grep -q "cd /vagrant" /home/vagrant/.bashrc ; then 
    echo -e "\ncd /vagrant\n" >> /home/vagrant/.bashrc 
fi 

echo -e "\n\nfinished!\n"