// HiGHS Scaffold header, to be included in HiGHS.

#ifndef TEST_PRESOLVE_HPP_
#define TEST_PRESOLVE_HPP_

#include <iostream>
#include <sstream>
#include <chrono>

#include "Highs.h"
#include "ScaffoldMethods.hpp"

namespace scaffold {
namespace test {

const std::string kFolder = "/Users/mac/test_pr/mps_da/";

struct TestRunInfo {
  TestRunInfo(std::string xname, double x_optimal_obj)
      : name(std::move(xname)), optimal_objective(x_optimal_obj) {}

  TestRunInfo(std::string xname, double xobj, int time)
      : name(std::move(xname)), objective(xobj) {
    time = time;
  }

  std::string name;
  double optimal_objective;

  double objective;

  double time = -1;
};

// TestLp 25fv47{"25fv47", 5.501846e+03};
// TestLp 80bau3b{"80bau3b", 9.872242e+05};

// const TestRunInfo 25fv47_w2("25fv47", 0, 81, 99, 304);
// const TestRunInfo 80bau3b_w2("80bau3b", 0, 672, 292, 1279);

void testInit() {
  // Print details.
  std::cout << "Qaps100 test: " << std::endl << std::endl;

  return;
}

void loadAndCheckTestRunInfo(const Highs& highs, TestRunInfo& info) {
  info.objective = highs.getObjectiveValue();
}

void printInfo(TestRunInfo& info, const bool desc) {
  if (desc) {
    std::cout << "scaffold-run-test-qap100, name, optimal, obj, time"
              << std::endl;
  } else {
    std::cout << "scaffold-run-test-presolve, " << info.name << ", "
              << info.optimal_objective << ", " << info.objective << ", "
              << std::endl;
  }
}

void testProblems() {
  TestRunInfo pr_25fv47("25fv47", 5.501846e+03);
  TestRunInfo pr_80bau3b{"80bau3b", 9.872242e+05};
  TestRunInfo pr_adlittle{"adlittle", 2.254950e+05};
  TestRunInfo pr_afiro{"afiro", -4.647531e+02};
  TestRunInfo pr_etamacro{"etamacro", -7.55715231e+02};

  std::vector<TestRunInfo> problems;
  problems.push_back(pr_25fv47);
  problems.push_back(pr_80bau3b);
  problems.push_back(pr_adlittle);
  problems.push_back(pr_afiro);
  problems.push_back(pr_etamacro);

  printInfo(problems[0], true);

  for (TestRunInfo& test_run : problems) {
    try {
      std::string file{kFolder + test_run.name + ".mps"};

      Highs highs;
      HighsStatus highs_status = highs.readModel(file);

      if (highs_status != HighsStatus::kOk) {
        std::cout << "TestPresolve:: Highs readModel returned Warning or Error "
                     "on problem: "
                  << test_run.name << std::endl;
        // continue;
        exit(2);  // so ctest can fail.
      }

      // Making sure presolve is on (default).
      highs.setOptionValue("presolve", "on");
      auto start = std::chrono::steady_clock::now();

      HighsStatus run_status = highs.run();
      auto end = std::chrono::steady_clock::now();

      std::cout << "Elapsed time in milliseconds: "
              << std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count()
              << " sec, ";

      if (run_status == HighsStatus::kOk) {
        // Load TestRunInfo
        loadAndCheckTestRunInfo(highs, test_run);
        test_run.time = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();

        // output main stats
        printInfo(test_run, false);

      } else {
        std::cout << "TestPresolve:: Highs run() returned Warning or Error on "
                     "problem: "
                  << test_run.name << std::endl;
      }
    } catch (int e) {
      std::cout << "TestPresolve:: Highs run() caught an exception on problem: "
                << test_run.name << std::endl;
    }
  }
  return;
}

void test() {
  testInit();
  testProblems();
}

void linkComponent() {
  std::cout << "link component" << std::endl;
  test();
  return;
}

}  // namespace test
}  // namespace scaffold

#endif