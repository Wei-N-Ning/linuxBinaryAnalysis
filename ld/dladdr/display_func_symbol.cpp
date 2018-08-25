
#include <iostream>
#include <string>
#include <vector>

#include <dlfcn.h>

// NOTE:
// dladdr() is used by boost backtrace component to display the symbol (mangled) name based on the runtime address given 
// it is also used by addr2line program
// experiment:
//
// and on addr2line side:
// experiment with this:
// addr2line -e /work/dev/cxx/github.com/powergun/cxxDebugGems/build/backtrace_boost/caller_boost 0x401cD1
// address 0x401cD1 is retrieved from readelf -e <bin>
// observe the start address of .text section and add a bit offset (0x200) to it
//
// see also:
// https://github.com/boostorg/stacktrace
// http://boostorg.github.io/stacktrace/stacktrace/configuration_and_build.html
// http://boostorg.github.io/stacktrace/stacktrace/getting_started.html#stacktrace.getting_started.handle_terminates_aborts_and_seg
// http://boostorg.github.io/stacktrace/stacktrace/getting_started.html#stacktrace.getting_started.how_to_print_current_call_stack
// http://boostorg.github.io/stacktrace/index.html
//
// source:
// if run with ticc:
// ticc run <path> -- -g -rdynamic -ldl
//
// -rdynamic and why it is needed here:
// https://stackoverflow.com/questions/11731229/dladdr-doesnt-return-the-function-name
// https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html

// man dladdr
// Dl_info structure member fields:
// 
// const char *dli_fname;  /* Pathname of shared object that
//                                          contains address */
//               void       *dli_fbase;  /* Base address at which shared
//                                         object is loaded */
//               const char *dli_sname;  /* Name of symbol whose definition
//                                          overlaps addr */

int foo(std::vector<int> i_values, std::string& o_str) {
    int a = 10;
    return a;
}

int main() {
    Dl_info info;
    dladdr((void *)foo, &info);

    std::cout << "filename: " << info.dli_fname << std::endl;
    
    std::cout << "symbol: " << info.dli_sname << std::endl;

    return 0;
}
