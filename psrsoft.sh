#!/bin/bash
###
#Set an editor (nano/vi/emacs/vim). Try not to use gedit.

EDITOR=nano

#To install to a custom directory edit the two lines below
PREFIX=$HOME/psrsoft
#Set the directory where source files are stored
SRCHOME=${PREFIX}/src

#Comment out these lines if yoiu are using /usr/local/
mkdir $PREFIX
mkdir $PREFIX/src
mkdir $PREFIX/lib
mkdir $PREFIX/bin
mkdir $PREFIX/share
mkdir $PREFIX/etc
mkdir $PREFIX/games
mkdir $PREFIX/include
mkdir $PREFIX/libexec
mkdir $PREFIX/man
mkdir $PREFIX/sbin

#append this path to your path variable
export PATH=${PREFIX}/bin:${PATH}
#set shared library path so that gcc knows where to link
export LD_LIBRARY_PATH=${PREFIX}/lib:$LD_LIBRARY_PATH

#Start installing
cd ${SRCHOME}
wget http://www.fftw.org/fftw-3.3.4.tar.gz && \
tar -xzf fftw-3.3.4.tar.gz && \
wget ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/cfitsio_latest.tar.gz && \
tar -xzf cfitsio_latest.tar.gz && \
wget ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz && \
tar -xzf pgplot5.2.tar.gz && \
wget http://www.atnf.csiro.au/people/pulsar/psrcat/downloads/psrcat_pkg.tar.gz && \
tar -xvf psrcat_pkg.tar.gz && \
wget http://www.imcce.fr/fr/presentation/equipes/ASD/inpop/calceph/calceph-2.3.0.tar.gz && \
tar -xvvf calceph-2.3.0.tar.gz && \
git clone https://bitbucket.org/psrsoft/tempo2.git && \
git clone git://git.code.sf.net/p/psrchive/code psrchive && \
git clone https://github.com/SixByNine/psrxml.git && \
git clone https://github.com/nextgen-astrodata/DAL.git
#git clone git://git.code.sf.net/p/dspsr/code dspsr && \


#install fftw:
cd fftw-3.3.4
./bootstrap.sh
./configure --enable-float --enable-shared
make
checkinstall

./configure --enable-shared
make clean
make
checkinstall
cd ${SRCHOME}

#we compiled FFTW twice to have both single and double precision libraries

#install cfitsio:
cd cfitsio
./configure --enable-reentrant --prefix=${PREFIX}
make
checkinstall
cd ${SRCHOME}

#install pgplot:
cd pgplot;
patch < ${SRCHOME}/psrchive/packages/makemake.sharedcpg.patch;
mkdir -p ${PREFIX}/share/pgplot;
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
export PGPLOT_FONT=${PGPLOT_DIR}/grfont.dat
echo 'export PGPLOT_DIR=${PREFIX}/share/pgplot' >> $HOME/.bashrc
echo 'export PGPLOT_FONT=${PGPLOT_DIR}/grfont.dat' >> $HOME/.bashrc
echo 'export PGPLOT_INCLUDES ${PREFIX}/include' >> $HOME/.bashrc
echo 'export PGPLOT_BACKGROUND white' >> $HOME/.bashrc
echo 'export PGPLOT_FOREGROUND black' >> $HOME/.bashrc
echo 'export PGPLOT_DEV /xs' >> $HOME/.bashrc
source $HOME/.bashrc

install libpgplot.a ${PREFIX}/lib/
install libcpgplot.a ${PREFIX}/lib/
install libcpgplot.so ${PREFIX}/lib/

cd ${SRCHOME}

# calceph
echo 'export CALCEPH ${PREFIX}/calceph-2.3.0' >> $HOME/.bashrc
echo 'export PATH $PATH:$CALCEPH/install/bin' >> $HOME/.bashrc
echo 'export LD_LIBRARY_PATH $CALCEPH/install/lib' >> $HOME/.bashrc
echo 'export C_INCLUDE_PATH $C_INCLUDE_PATH:$CALCEPH/install/include' >> $HOME/.bashrc
source $HOME/.bashrc

cd calceph-2.3.0 #$CALCEPH
./configure --prefix=$CALCEPH/install --with-pic --enable-shared --enable-static --enable-fortran --enable-thread && \
    make && \
    make check && \
    checkinstall && \
    rm -f ../calceph-2.3.0.tar.gz
cd ${SRCHOME}

# Data Access Library
echo 'export DAL ${PREFIX}/DAL' >> $HOME/.bashrc
echo 'export PATH $PATH:$DAL/install/bin' >> $HOME/.bashrc
echo 'export C_INCLUDE_PATH $C_INCLUDE_PATH:$DAL/install/include' >> $HOME/.bashrc
echo 'export LD_LIBRARY_PATH $LD_LIBRARY_PATH:$DAL/install/lib' >> $HOME/.bashrc
source $HOME/.bashrc

cd  $DAL
mkdir build
cd  $DAL/build
cmake .. -DCMAKE_INSTALL_PREFIX=$DAL/install && \
    make -j $(nproc) && \
    make && \
    make install
cd ${SRCHOME}

# Psrcat
echo 'export PSRCAT_FILE ${PREFIX}/psrcat_tar/psrcat.db' >> $HOME/.bashrc
echo 'export PATH $PATH:${PREFIX}/psrcat_tar' >> $HOME/.bashrc
source $HOME/.bashrc
cd  ${PREFIX}/psrcat_tar
/bin/bash makeit && \
    rm -f ../psrcat_pkg.tar.gz
cd ${SRCHOME}

# PSRXML
echo 'export PSRXML ${PREFIX}/psrxml' >> $HOME/.bashrc
echo 'export PATH $PATH:$PSRXML/install/bin' >> $HOME/.bashrc
echo 'export LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRXML/install/lib' >> $HOME/.bashrc
echo 'export C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRXML/install/include' >> $HOME/.bashrc
source $HOME/.bashrc
cd  $PSRXML
autoreconf --install --warnings=none
./configure --prefix=$PSRXML/install && \
    make && \
    make install && \
    rm -rf .git
cd ${SRCHOME}

#install tempo:
cd ${SRCHOME}/
git clone git://git.code.sf.net/p/tempo/tempo
cd tempo
./prepare #./preparemake is now called prepare?
./configure
make
checkinstall
export TEMPO=${SRCHOME}/tempo
echo 'export TEMPO=${SRCHOME}/tempo' >> $HOME/.bashrc

#install tempo2:
cd ${SRCHOME}
echo 'export TEMPO2 $PSRHOME/tempo2/T2runtime' >> $HOME/.bashrc
echo 'export PATH $PATH:$PSRHOME/tempo2/T2runtime/bin' >> $HOME/.bashrc
echo 'export C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRHOME/tempo2/T2runtime/include' >> $HOME/.bashrc
echo 'export LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/tempo2/T2runtime/lib' >> $HOME/.bashrc
source $HOME/.bashrc

cd /tempo2
sync && perl -pi -e 's/chmod \+x/#chmod +x/' bootstrap # Get rid of: returned a non-zero code: 126.
./bootstrap && \
    ./configure --x-libraries=/usr/lib/x86_64-linux-gnu --with-calceph=$CALCEPH/install/lib --enable-shared --enable-static --with-pic F77=gfortran CPPFLAGS="-I"$CALCEPH"/install/include" && \
    make -j $(nproc) && \
    checkinstall && \
    make plugins-install && \
    rm -rf .git

cd ${SRCHOME}


#First, download psrchive
git clone git://git.code.sf.net/p/psrchive/code psrchive;
#Then, install psrchive:
cd ${SRCHOME}/psrchive
./bootstrap
./configure  --enable-shared
make clean
make
checkinstall

echo 'export PSRCHIVE $PSRHOME/psrchive' >> $HOME/.bashrc
echo 'export PATH $PATH:$PSRCHIVE/install/bin' >> $HOME/.bashrc
echo 'export C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRCHIVE/install/include' >> $HOME/.bashrc
echo 'export LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRCHIVE/install/lib' >> $HOME/.bashrc
echo 'export PYTHONPATH $PSRCHIVE/install/lib/python2.7/site-packages' >> $HOME/.bashrc
source $HOME/.bashrc

cd $PSRCHIVE
./bootstrap && \
    ./configure --prefix=$PSRCHIVE/install --x-libraries=/usr/lib/x86_64-linux-gnu --with-psrxml-dir=$PSRXML/install --with-cfitsio-lib-dir=${SRCHOME}/cfitsio/ --with-fftw3-dir=${SRCHOME}/fftw-3.3.4/ --enable-shared --enable-static F77=gfortran LDFLAGS="-L"$PSRXML"/install/lib" LIBS="-lpsrxml -lxml2" && \
    make -j $(nproc) && \
    make && \
    checkinstall && \
    rm -rf .git
cd $HOME
echo "Predictor::default = tempo2" >> .psrchive.cfg && \
echo "Predictor::policy = default" >> .psrchive.cfg && \
echo "Dispersion::barycentric_correction = 1" >> .psrchive.cfg
cd ${SRCHOME}

###
#In the words of Yoda:
#You now have psrchive, installed.
###

#Add temponest

#CoastGuard
#git clone gitosis@git.mpifr-bonn.mpg.de:coast_guard.git
git clone https://github.com/plazar/coast_guard.git
#export COASTGUARD_CFG=/usr/share/coastguard
#sudo mkdir /usr/share/coastguard
#sudo cp -R . /usr/share/coastguard/
#export COASTGUARD_CFG=/usr/share/coastguard/configurations/
#clean.py --list-cleaners

#In utils.py line 638, remove < asite >
${EDITOR} utils.py

#Tempo2 - edit /{tempo2home}/plugins/
#add 4DCube_plug.c (from Herbert) /usr/local/src/tempo2
#modify plugins/plugin_lists/pgplot.plugins
#append 4DCube_plug.c