#!/bin/bash
###
#This script installs the following packages:
#01) cfitsio 
#02) FFTW (or IPP or MKL) 
#03) git 
#04) cvs 
#05) Gnu Scientific Library 
#06) Healpix 
#07) pgplot ​(not mandatory but highly recommended)
#08) psrcat ​(not mandatory but highly recommended) 
#09) tempo ​(in principle not mandatory but quite recommended) 
#10) tempo2 
#11) psrchive
###

#Pre-install steps!

#Uncomment the line below if you have a barebones Ubuntu system only
sudo apt-get install build-essential gfortran dh-autoreconf git cvs libx11-dev libpng12-dev csh swig python-dev python python-numpy libltdl-dev

#Uncomment the line below if you have a barebones Fedora system only
#sudo yum install build-essential gfortran dh-autoreconf git cvs libx11-dev libpng12-dev csh swig python-dev python python-numpy libltdl-dev

###
#The lines above will install, for a freshly installed OS, the following packages:
#1) gcc 
#2) gfortran 
#3) X11 libraries and headers 
#4) autotools / autoconf 
#5) libtool 
#6) make 
#7) png (optional, to enable PNG support in pgplot) 
###

#Set an editor (nano/vi/emacs/vim). Try not to use gedit.
EDITOR=nano

#The installation is done in the usr/local/src directory by default
PREFIX=/usr/local

#To install to a custom directory edit the two lines below
mkdir ~/pulsar_home
PREFIX=~/pulsar_home/

#Set the directory where source files are stored
SRCHOME=${PREFIX}/src

#append this path to your path variable
export PATH=${PREFIX}/bin:${PATH}
#set shared library path so that gcc knows where to link
export LD_LIBRARY_PATH=${PREFIX}/lib:$LD_LIBRARY_PATH

###
#'Also sprach Zarathustra':
#1) The default installation will not work unless you have read / write 
#permissions in /usr/local and that /usr/local/lib is present, e.g., in  
#/etc/ld.so.conf.d/local.conf or other file. 
#2) If not, then run as superuser: 
#echo ‘/usr/local/lib/’ >> /etc/ld.so.conf.d/local.conf 
#ldconfig 
#chmod ­R a+w /usr/local/ 
#3) Note that the steps above may be undesirable for a variety of reasons for a shared 
#computer or impossible if you don’t have root access. If so, then you need to install 
#software in a custom location by changing the PREFIX variable. 
#Suggested reading : psrchive’s webpage.
###

#Start installing 
cd ${SRCHOME}

#install fftw:
wget http://www.fftw.org/fftw-3.3.4.tar.gz
tar -xzf fftw-3.3.4.tar.gz
cd fftw-3.3.4
./bootstrap.sh
./configure --enable-float --enable-shared 
make
make install

./configure --enable-shared
make clean
make
make install
cd ../
#we compiled FFTW twice to have both single and double precision libraries

#install cfitsio:
wget ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/cfitsio_latest.tar.gz
tar -xzf cfitsio_latest.tar.gz
cd cfitsio
./configure --enable-reentrant --prefix=${PREFIX}
make
make install
cd ..

#install pgplot:
wget ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz;
tar -xzf pgplot5.2.tar.gz;
cd pgplot;
patch < ${SRCHOME}/psrchive/packages/makemake.sharedcpg.patch;
mkdir ­-p ${PREFIX}/share/pgplot;
cp drivers.list ${PREFIX}/share/pgplot/;
cd ${PREFIX}/share/pgplot;
#edit the ${PREFIX}/share/pgplot/drivers.list file to include whatever drivers you want. 
#Typically that would be PNDRIV 1 and 2; PSDRIV 1, 2, 3, and 4; XWDRIV 1, and 2. 
#Remove the exclamation mark to uncomment a desired driver.
${EDITOR} drivers.list
${SRCHOME}/pgplot/makemake ${SRCHOME}/pgplot linux g77_gcc_aout

#edit makefile and replace g77 with gfortran, if necessary
#If you included PNDRIV, you need to remove / comment out (with a hash) a line
#‘pndriv.o : ./png.h ./pngconf.h ./zlib.h ./zconf.h’ in ${SRCHOME}/pgplot/makefile
echo "In the nextstep, edit the makefile and replace g77 with gfortran, if necessary."
sleep 3
echo -e "If you included PNDRIV, you also need to comment out (with a hash) the line:\n ‘pndriv.o : ./png.h ./pngconf.h ./zlib.h ./zconf.h’"
sleep 10
${EDITOR} makefile
make
make cpg
make pgxwin_server
make grfont.dat
export PGPLOT_DIR=${PREFIX}/share/pgplot
echo 'export PGPLOT_DIR=${PREFIX}/share/pgplot' >> ~/.bashrc
export PGPLOT_FONT=${PGPLOT_DIR}/grfont.dat
echo 'export PGPLOT_FONT=${PGPLOT_DIR}/grfont.dat' >> ~/.bashrc
install libpgplot.a ${PREFIX}/lib/
install libcpgplot.a ${PREFIX}/lib/
install libcpgplot.so ${PREFIX}/lib/

#install tempo:
cd ${SRCHOME}/
git clone git://git.code.sf.net/p/tempo/tempo
cd tempo
./prepare #./preparemake is now called prepare?
./configure
make
make install
export TEMPO=${SRCHOME}/tempo
echo 'export TEMPO=${SRCHOME}/tempo' >> ~/.bashrc

#install tempo2:
cd ${SRCHOME}
cvs -z3 -d:pserver:anonymous@tempo2.cvs.sourceforge.net:/cvsroot/tempo2 co -P tempo2
cd tempo2
./bootstrap
mkdir -p ${PREFIX}/share/tempo2
cp -r T2runtime/* ${PREFIX}/share/tempo2/
export TEMPO2=${PREFIX}/share/tempo2
echo 'export TEMPO2=${PREFIX}/share/tempo2' >> ~/.bashrc
CFLAGS=-pthread 
./configure --prefix=${PREFIX}/
make
make plugins
make install
make plugins-install

#First, download psrchive
git clone git://git.code.sf.net/p/psrchive/code psrchive;
#Then, install psrchive:
cd ${SRCHOME}/psrchive
./bootstrap
./configure --with-cfitsio-lib-dir=${SRCHOME}/cfitsio/ --with-fftw3-dir=${SRCHOME}/fftw-3.3.4/ --enable-shared
make clean
make
make install
###
#In the words of Yoda:
#You now have psrchive, installed.
###

#Add temponest

#CoastGuard
#----------
#! Requires whitelisting of public ssh key:
#ssh-keygen -t rsa -C "jkuensem@physik.uni-bielefeld.de"
#cat ~/.ssh/id_rsa.pub
#---
#git clone gitosis@git.mpifr-bonn.mpg.de:coast_guard.git
git clone https://github.com/plazar/coast_guard.git
export COASTGUARD_CFG=/usr/share/coastguard
sudo mkdir /usr/share/coastguard
sudo cp -R . /usr/share/coastguard/
export COASTGUARD_CFG=/usr/share/coastguard/configurations/
clean.py --list-cleaners

#In utils.py line 638, remove < asite >
${EDITOR} utils.py

#Tempo2 - edit /{tempo2home}/plugins/
#add 4DCube_plug.c (from Herbert) /usr/local/src/tempo2
#modify plugins/plugin_lists/pgplot.plugins
#append 4DCube_plug.c


echo "Congratulations on your mintyfresh install! Remember to check your ~/.bashrc (or ~/.zshrc or ~/.cshrc)."
