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

#Uncomment the line below if you have a barebones Ubuntu system only
sudo apt-get install build-essential gfortran dh-autoreconf git cvs libx11-dev libpng12-dev csh swig python-dev python python-numpy libltdl-dev

#Uncomment the line below if you have a barebones Ubuntu system only
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

###
#'Also sprach Zarathustra':
#1) I assume here that you have read / write permissions in /usr/local and that 
#/usr/local/lib is present, e.g., in  /etc/ld.so.conf.d/local.conf or other file. 
#2) If not, then run as superuser: 
#echo ‘/usr/local/lib/’ >> /etc/ld.so.conf.d/local.conf 
#ldconfig 
#chmod ­R a+w /usr/local/ 
#3) Note that the steps above may be undesirable for a variety of reasons for a shared 
#computer or impossible if you don’t have root access. If so, then you need to install 
#software in a custom location in a very similar manner as below. See also
#psrchive’s webpage
###

#The installation is done in the usr/local/src directory by default
cd /usr/local/src;

#set shared library path so that gcc knows where to link
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

#download psrchive
git clone git://git.code.sf.net/p/psrchive/code psrchive;

#install fftw:
wget http://www.fftw.org/fftw-3.3.4.tar.gz
tar -xzf fftw-3.3.4.tar.gz
cd fftw-3.3.4
./bootstrap.sh
./configure --enable-float --enable-shared 
make
make install

./configure­--enable-shared
make clean
make
make install
cd ../
#we compiled FFTW twice to have both single and double precision libraries

#install cfitsio:
wget ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/cfitsio_latest.tar.gz
tar -xzf cfitsio_latest.tar.gz
cd cfitsio
./configure --enable-reentrant --prefix=/usr/local
make
make install
cd ..

#install pgplot:
wget ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz;
tar -xzf pgplot5.2.tar.gz;
cd pgplot;
patch < /usr/local/src/psrchive/packages/makemake.sharedcpg.patch;
mkdir ­p /usr/local/share/pgplot;
cp drivers.list /usr/local/share/pgplot/;
cd /usr/local/share/pgplot;
#edit the /usr/local/share/pgplot/drivers.list file to include whatever drivers you want. 
#Typically that would be PNDRIV 1 and 2; PSDRIV 1, 2, 3, and 4; XWDRIV 1, and 2. 
#Remove the exclamation mark to uncomment a desired driver.
nano drivers.list
/usr/local/src/pgplot/makemake /usr/local/src/pgplot linux g77_gcc_aout

#edit makefile and replace g77 with gfortran, if necessary
#If you included PNDRIV, you may need to remove / comment out (with a hash) a line
#‘pndriv.o : ./png.h ./pngconf.h ./zlib.h ./zconf.h’ in /usr/local/src/pgplot/makefile
echo "In the nextstep, edit the makefile and replace g77 with gfortran, if necessary."
sleep 3
echo -e "If you included PNDRIV, you also need to comment out (with a hash) the line:\n ‘pndriv.o : ./png.h ./pngconf.h ./zlib.h ./zconf.h’"
sleep 10
nano makefile
make
make cpg
make pgxwin_server
make grfont.dat
export PGPLOT_DIR=/usr/local/share/pgplot
echo 'export PGPLOT_DIR=/usr/local/share/pgplot' >> ~/.bashrc
export PGPLOT_FONT=${PGPLOT_DIR}/grfont.dat
echo 'export PGPLOT_FONT=${PGPLOT_DIR}/grfont.dat' >> ~/.bashrc
install libpgplot.a /usr/local/lib/
install libcpgplot.a /usr/local/lib
install libcpgplot.so /usr/local/lib

#install tempo:
cd /usr/local/src/
git clone git://git.code.sf.net/p/tempo/tempo
cd tempo
./prepare #./preparemake is now called prepare?
./configure
make
make install
export TEMPO=/usr/local/src/tempo
echo 'export TEMPO=/usr/local/src/tempo' >> ~/.bashrc

#install tempo2:
cd /usr/local/src
#This should be your fall back and is not gauranteed to work
#cvs -z3 -d:pserver:anonymous@tempo2.cvs.sourceforge.net:/cvsroot/tempo2 co -P tempo2
git clone https://bitbucket.org/psrsoft/tempo2.git
cd tempo2
./bootstrap
mkdir -p /usr/local/share/tempo2
cp -r T2runtime/* /usr/local/share/tempo2/
export TEMPO2=/usr/local/share/tempo2
echo 'export TEMPO2=/usr/local/share/tempo2' > ~/.bashrc
CFLAGS=-pthread ./configure --prefix=/usr/local/
make
make plugins
make install
make plugins-install


#install psrchive:
cd /usr/local/src/psrchive
./bootstrap
./configure --with-cfitsio-lib-dir=/usr/local/src/cfitsio/ --with-fftw3-dir=/usr/local/src/fftw-3.3.4/ --enable-shared
make clean
make
make install
###
#In the words of Yoda:
#You now have psrchive, installed.
###
