
#include <iostream>

#include "../qaps100/Test.hpp"
#include "../scaffold/ScaffoldMethods.hpp"

int main(int argc, char* argv[]) {
  // Use a scaffold utility.
  scaffold::ScaffoldUtils::scaffoldHello();

  // Call test on presolve component.
  scaffold::test::linkComponent();

  // Dev code should be compiled and used with a target specified in its
  // dev-*/CMakeLists.txt.
  std::cout << "End of Scaffold: return 0." << std::endl;

  return 0;
}