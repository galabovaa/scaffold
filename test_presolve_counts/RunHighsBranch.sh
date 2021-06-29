#!/bin/bash

# Runs tests on presolve.
BRANCH="master"

# Additionally run tests on make install.
# Netlib with default HiGHS settings.

HIGHS_ROOT="/Users/mac/projects/HiGHS"
# So far using branch dev-ig
SCAFFOLD_DIR="/Users/mac/projects/scaffold"
TEST_DIR="/Users/mac/test_pr"

CURRENT_DIR="${SCAFFOLD_DIR}/test_presolve_counts"
TMP_DIR="/Users/mac/run/test"

# Create folder for cmake tests output here
cd ${TMP_DIR}

# keep code for ref
#RUN_DIR=$(date +%Y%m%d_%H%M%S)
# don't keep code for ref
RUN_DIR="$(date +%Y%m%d_)${BRANCH}"

mkdir ${RUN_DIR}

cd ${RUN_DIR}
cp -r ${HIGHS_ROOT} .

cd HiGHS
HIGHS_RUN_DIR=${TMP_DIR}/${RUN_DIR}/HiGHS

# check branch out
echo ${HIGHS_RUN_DIR}
cd ${HIGHS_RUN_DIR}
git checkout ${BRANCH}

# Copy relevant scaffold directories and edit main CMakeLists.txt of HiGHS.
# First scaffold only.
cp -r ${SCAFFOLD_DIR}/scaffold ${HIGHS_RUN_DIR}
cp -r ${SCAFFOLD_DIR}/component_test ${HIGHS_RUN_DIR}

rm -rf build
mkdir build
cd build
cmake .. | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

cmake --build --parallel . | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
make -j | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
ctest | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

# Save log.
cp ${HIGHS_RUN_DIR}/build/Testing/Temporary/LastTest.log \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_S_only.log

# Then Scaffold and TestPresolve.
rm ${HIGHS_RUN_DIR}/scaffold/ScaffoldMain.cpp
cp ${SCAFFOLD_DIR}/component_test/TestScaffoldMain.cpp ${HIGHS_RUN_DIR}/scaffold/ScaffoldMain.cpp

echo "add_subdirectory(scaffold)" | tee -a ${HIGHS_RUN_DIR}/CMakeLists.txt

cmake -DCMAKE_INSTALL_PREFIX=${TMP_DIR}/${RUN_DIR}/install \
    .. | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

cmake --build . | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
make -j | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
ctest | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

# Save log.
cp ${HIGHS_RUN_DIR}/build/Testing/Temporary/LastTest.log \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_TP.log
cd ${TMP_DIR}

# Install HiGHS.
cd ${RUN_DIR}
mkdir install
cd ${HIGHS_RUN_DIR}/build
make install

# Netlib.
for file in ${TEST_DIR}/netlib/*.mps; do
    ${TMP_DIR}/${RUN_DIR}/install/bin/highs --time_limit=3000 ${file} |
        tee -a ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_netlib.log
done

# Smaller instance.
${TMP_DIR}/${RUN_DIR}/install/bin/highs --time_limit=10000 \
    ${TEST_DIR}/small.mps | tee -a \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_small.log
