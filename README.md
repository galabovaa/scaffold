## Scaffold for HiGHS 1.0

- Unit Tests
- Extended Instance Tests
- Interface Tests
- Problem Sets
- Component Tests
- Development code

Containts extended tests and problem sets, as well as a log of performance of previous versions of ERGO-Code/HiGHS.git master.

### Unit tests

Catch2 has been updated and it is looking even nicer and simpler than before, but https://github.com/onqtam/doctest has better feedback from devs. GoogleTest unit tests have too large a machinery around them.

### Extended instance tests

- use cmake to run HiGHS on netlib / qaps (test set)
  - can be done in the same way as the ctest instance add
- todo: use julia to run HiGHS on a (julia test set)

### Interface tests

- todo: use highslib from julia

### Design

The division of folders in scaffold is such that it allows for linking dev code with scaffold utilities easily and allows adding and removing tests. This allows for maintainance of the modular structure of the scaffold. It will also enable easy transition of code from the pre-release master out into scaffold while making sure everything works. So, the code (HiGHS) and the test code (scaffold) can be used together but no get out of sync, since it will be clearly separated whether code belongs to the scaffold/ and if so, to which part:

- scaffold/component_tests/
  containing tests for components of HiGHS (like presolve) to be tested with each update of master and to be used for development
- scaffold/scaffold/
  contains scaffold utilities and defines the executable which will run all component tests we want to run on HiGHS
  dev executables are defined in their own scaffold root subdirecties


dev-presolve/ is an example of use of the scaffold for development. It is an example of a folder which can exist locally (or on any git branch of this repo) which can be copied into HiGHS for development or test of that component (along with the scaffold/ dir).

### Performance Log

Scaffold can be set up to keep a record of the performance on HiGHS on various test sets.
