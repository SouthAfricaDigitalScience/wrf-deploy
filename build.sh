#!/bin/bash -e
# WRF build script
. /etc/profile.d/modules.sh
module add ci
module add gcc/5.1.0
module add  mpich/3.2-gcc-5.1.0
module add netcdf/4.3.2-gcc-4.9.2-mpi-1.8.8
module add hdf5/1.8.16-gcc-5.1.0-mpich

# The source file is WRFV3.8.TAR.gz

SOURCE_FILE=${NAME}V${VERSION}.TAR.gz

echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
  wget http://www2.mmm.ucar.edu/wrf/src/${SOURCE_FILE} -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi
tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
cd ${WORKSPACE}/WRFV3
export NETCDF=$NETCDF_DIR

# Following http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php#STEP1
# there are some tests which we can run to check if the build will go ok.

mkdir -p BUILD_WRF TESTS
# we do the fortran tests :
cd TESTS
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar -O Fortran_C_tests.tar
tar xf Fortran_C_tests.tar
gcc -c -m64 TEST_4_fortran+c_c.c
gfortran -c -m64 TEST_4_fortran+c_f.f90
gfortran -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o


echo 35 | ./configure
# configure....
#make -j 2
echo hi
