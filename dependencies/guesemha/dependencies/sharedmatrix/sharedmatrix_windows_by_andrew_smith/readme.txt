Andrew Smith
Recommendations on how to install on Windows:

First, you need boost libraries. 
Second, cd to the sharedmatrix_windows... folder 
Third, copy the struct 'mxArray_tag' from sharedmatrix.h file into SharedMemory.hpp 
Fourth, add the line 
#define BOOST_DATE_TIME_NO_LIB 
before the first boost #include in SharedMemory.hpp

Okba Bekhelifi
Update 22-Jul-2018: 
- Instructions to compile SharedMemory on windows:
1) The fixes cited above are aleardy added.
2) Download the windows binaries for boost (only MSVC compiler available):
(at the time of writing this update, version 1.67 was the latest stable) 
https://dl.bintray.com/boostorg/release/1.67.0/binaries/
3) Install the binaries.(they'll be added in C:\program files).
4) Make sure that mex is configured with a MSVC compiler.
5) Proceed to SharedMemory installation by running the SharedMemory_install
function.
Note:
- A compiled 64-bit mex function (built using MSVC 2013) is shipped with 
the toolbox ready to be  used in MATLAB. a new compilation is needed 
in the case of using different boost versions or/and compilers.