#!/bin/bash

# Runs tests on presolve.
BRANCH="fast-build"

# Additionally run tests on make install.
# Netlib with default HiGHS settings.

HIGHS_ROOT="/Users/mac/projects/HiGHS"
# So far using branch dev-ig
SCAFFOLD_DIR="/Users/mac/projects/scaffold"

CURRENT_DIR="${SCAFFOLD_DIR}/test_presolve_counts"
TMP_DIR="/Users/mac/run/dev"

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

rm -rf build
mkdir build
cd build
cmake .. | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

cmake --build --parallel . | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
make -j | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
ctest | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

# Save log.
cp ${HIGHS_RUN_DIR}/build/Testing/Temporary/LastTest.log \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_H_only.log

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
grep dev-presolve \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_HS.log > \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_HS_reduction_counts.log

# Then Scaffold and DevPresolve
cp -r ${SCAFFOLD_DIR}/dev_presolve ${HIGHS_RUN_DIR}
rm ${HIGHS_RUN_DIR}/scaffold/ScaffoldMain.cpp

cp ${SCAFFOLD_DIR}/dev_presolve/DevScaffoldMain.cpp ${HIGHS_RUN_DIR}/scaffold/ScaffoldMain.cpp

# Had issue with linking of CMake when using add_subdir.
# More modern CMake approach should fix that: added FAST_BUILD
echo "add_subdirectory(dev_presolve)" | tee -a ${HIGHS_RUN_DIR}/CMakeLists.txt

cd ${HIGHS_RUN_DIR}/build
cmake .. | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

cmake --build --parallel . | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
make -j | tee -a ${TMP_DIR}/${RUN_DIR}/build.log
ctest | tee -a ${TMP_DIR}/${RUN_DIR}/build.log

# Save log.
cp ${HIGHS_RUN_DIR}/build/Testing/Temporary/LastTest.log \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_dev_presolve.log
cd ${TMP_DIR}
grep dev-presolve \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_dev_presolve.log > \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_dev_presolve_reduction_counts.log

# Dev Tests
for file in ${TEST_DIR}/dev/*.mps; do
   ${HIGHS_RUN_DIR}/build/bin/highs --time_limit=3000 ${file} |
        tee -a ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_dev_mps.log
done
grep dev-presolve ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_dev_mps.log > \
    ${TMP_DIR}/${RUN_DIR}/${RUN_DIR}_dev_mps_reduction_counts.log
