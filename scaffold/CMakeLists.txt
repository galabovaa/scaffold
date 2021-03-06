# Define executable(s) to build. The scaffold executable will run tests we would
# like to run on each update of master. For test or dev it can also define and
# link with dev- and test- components.

add_library(test-presolve INTERFACE)
target_sources(test-presolve
               INTERFACE ${HIGHS_SOURCE_DIR}/component_test/TestPresolve.hpp)
target_include_directories(test-presolve
                           INTERFACE ${HIGHS_SOURCE_DIR}/component_test)

add_executable(scaffold)

target_include_directories(
  scaffold PUBLIC ${HIGHS_SOURCE_DIR}/src/io
                  ${HIGHS_SOURCE_DIR}/scaffold)

target_sources(scaffold PUBLIC ${HIGHS_SOURCE_DIR}/scaffold/ScaffoldMain.cpp)

target_link_libraries(scaffold libhighs)

add_test(NAME scaffold COMMAND scaffold)
        set_tests_properties (scaffold PROPERTIES
                PASS_REGULAR_EXPRESSION
                "End of Scaffold: return 0.")