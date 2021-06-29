#include <iostream>

// Enable for component_test/
// #include "../component_test/TestPresolve.hpp"
#include "../scaffold/ScaffoldMethods.hpp"

int main(int argc, char* argv[]) {
  // Use a scaffold utility.
  scaffold::ScaffoldUtils::scaffoldHello();

  // Call test on presolve component.
  // scaffold::test_presolve::linkComponent();

  // Dev code should be compiled and used with a target specified in its
  // dev-*/CMakeLists.txt.
  std::cout << "End of Scaffold: return 0." << std::endl;

  return 0;
}