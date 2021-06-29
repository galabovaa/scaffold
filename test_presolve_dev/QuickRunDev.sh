#!/bin/bash

BRANCH="install"

# Additionally run tests on make install.
# Netlib with default HiGHS settings.

HIGHS_ROOT="/Users/mac/projects/HiGHS"
# So far using branch installs
SCAFFOLD_DIR="/Users/mac/projects/scaffold"

TMP_DIR="/Users/mac/run/dev"

# Create folder for cmake tests output here
cd ${TMP_DIR}

# keep code for ref
#RUN_DIR=$(date +%Y%m%d_%H%M%S)
# don't keep code for ref
RUN_DIR="quick_run_dev$(date +%Y%m%d_)${BRANCH}"

mkdir ${RUN_DIR}

cd ${RUN_DIR}
cp -r ${HIGHS_ROOT} .

cd HiGHS
HIGHS_RUN_DIR=${TMP_DIR}/${RUN_DIR}/HiGHS

# check branch out
echo ${HIGHS_RUN_DIR}
cd ${HIGHS_RUN_DIR}
git checkout ${BRANCH}

rm -rf build
mkdir build
cd build
cmake -DFAST_BUILD=ON .. | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

cmake --build --parallel . | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
make -j | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

# Then Scaffold.

# Copy relevant scaffold directories and edit main CMakeLists.txt of HiGHS.
# First scaffold only.
cp -r ${SCAFFOLD_DIR}/scaffold ${HIGHS_RUN_DIR}
echo "" | tee -a ${HIGHS_RUN_DIR}/CMakeLists.txt
echo "add_subdirectory(scaffold)" | tee -a ${HIGHS_RUN_DIR}/CMakeLists.txt

cmake --build --parallel . | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
make -j | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
ctest | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

# Save log.
cp ${HIGHS_RUN_DIR}/build/Testing/Temporary/LastTest.log \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_HS.log
cd ${TMP_DIR}
