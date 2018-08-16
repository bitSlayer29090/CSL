# CMake generated Testfile for 
# Source directory: /cluster/2020shachem/CSL/nestCompile9/nest-simulator-2.14.0/pynest
# Build directory: /cluster/2020shachem/CSL/nestCompile9/nest-simulator-2.14.0/pynest
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(PyNEST "/cluster/2020shachem/miniconda3/bin/nosetests" "-v" "--with-xunit" "--xunit-file=/cluster/2020shachem/CSL/nestCompile9/nest-simulator-2.14.0/reports/pynest_tests.xml" "/cluster/2020shachem/nestInstall/lib64/python3.6/site-packages/nest/tests")
