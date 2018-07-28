#!/usr/bin/env bash

# source:
# https://blog.packagecloud.io/eng/2016/03/14/how-does-ltrace-work/

set -e 
CC=${CC-cc}
CXX=${CXX-c++}
DBG=${DBG-gdb}

# strace is a system call and signal tracer. It is primarily used to 
# trace system calls (that is, function calls made from programs to 
# the kernel), print the arguments passed to system calls, print return 
# values, timing information and more
# it also trace and output information about signals received by the 
# process

# see also:
# https://blog.packagecloud.io/eng/2016/02/29/how-does-strace-work/
# strace relies on ptrace() system call

# ltrace is a library call tracer and it is primarily used to trace 
# calls made by programs to library functions. It can also trace 
# system calls and signals like strace.

# both programs have some similar command line options for things like 
# printing timing information, return values, attaching to running 
# processes, and following forked processes

# ltrace also relies on the ptrace() system call, but tracing library 
# functions works differently than tracing system calls and this is 
# where the tools differ.

# //////// PLT ////////
# ELF binary format - procedure linkage table
# the plt contains a group pf assembly instructions per library func
# that executes when a library function is called. Groups of assembly 
# instructions are often called "trampolines"
# NOTE {
# this directly answers my previous question (documented in gdbPit 
# project)
# 
# }

# all the entries in the PLT follow the same template

display_plt() {
    cat >/tmp/ido.c << "EOF"    
#include <stdio.h>
void ido() { printf("asd\n"); } 
int main() { ido(); return 0; }
EOF
    ${CC} -o /tmp/ido /tmp/ido.c
    
    # show sections:
    # readelf -x .plt /tmp/ido
    # readelf -x .plt.got /tmp/ido
    # readelf -x .got /tmp/ido
    # readelf -x .got.plt /tmp/ido
    
    # objdump hint
    # see: https://www.cs.swarthmore.edu/~newhall/unixhelp/binaryfiles.html
    local oneliner=$( cat << "EOF"
BEGIN { my $start = 0; };
$start = 4 if /GLOBAL_OFFSET_TABLE/;
if ($start && $start > 0) {
    print $_;
    $start--;
}
EOF
)
    objdump -d /tmp/ido | perl -lne "${oneliner}" 
}
display_plt

# 0000000000400400 <puts@plt>:
#  400400: ff 25 12 0c 20 00     jmpq   *0x200c12(%rip)  # 601018 <_GLOBAL_OFFSET_TABLE_
#  400406: 68 00 00 00 00        pushq  $0x0
#  40040b: e9 e0 ff ff ff        jmpq   4003f0 <_init+0x28>
#
#  400410: ff 25 0a 0c 20 00     jmpq   *0x200c0a(%rip)  # 601020 <_GLOBAL_OFFSET_TABLE_
#  400416: 68 01 00 00 00        pushq  $0x1
#  40041b: e9 d0 ff ff ff        jmpq   4003f0 <_init+0x28>

# the code starts by jumping to the address stored in an entry in the 
# GOT

# the GOT contains a list of absolute addresses. At program start, these
# addresses are initialized to point to the pushq instruction inside 
# PLT

# the pushq code executes to store some data for the dynamic linker 
# and the jmp transfers execution to another piece of code that calls 
# into the dynamic linker

# the dynamic linker then uses the value $index1 and other data to 
# find out which library function the program tried to call.
# it locates the address of the library function and writes it to the 
# entry in the GOT //////// overwriting the previous entry which 
# pointed inside of the PLT ////////

# //////// Any call to the same library function after this point will
# execute the function directly instead of invoking the dynamic 
# linker, but still via the PLT entry!! ////////

# this means function@plt is called AS MANY TIMES as function it self.

# //////// see https://blog.packagecloud.io/eng/2016/03/14/how-does-ltrace-work/
# for a good 7-point summary of this process ////////

# To verify the last part, here is a demo

# lib.c: contains a function, int multiplyTwo(int, int);
# app.c: uses the library function more than once

# in GDB, expect the trampolines multiplyTwo@plt is called as many times 
# as the actual function multiplyTwo() is (and during the first call the 
# linker updates the GOT), 

# after the first call the address of multiply() in GOT will 
# point to its real address in the process memory, but multiply@plt 
# is still called for redirection
expect_trampolines_called() {
    cat >/tmp/lib.c << "EOF"
int multiplyTwo(int a, int b) {
    return a * b;
}
EOF
    ${CC} -fPIC -shared /tmp/lib.c -o /tmp/lib.so
    
    cat >/tmp/app.c << "EOF"
extern int multiplyTwo(int a, int b);
void compute() {
    int a = multiplyTwo(23, 11);
    int b = multiplyTwo(-12, 21);
    int c = 0;
    if (a + 2 * b > 0) {
        c = multiplyTwo(a, b);
    } 
    else {
        c = multiplyTwo(1, 2);
    }
}
int main() {
    compute();
    return 0;
}
EOF
    ${CC} /tmp/app.c \
        -o /tmp/app /tmp/lib.so \
        -Wl,-rpath="\$ORIGIN" \
        -Wl,-z,origin

    cat >/tmp/commands.txt << "EOF"
start
rb multiplyTwo@plt
c
c
c
EOF
    ${DBG} -batch -command=/tmp/commands.txt /tmp/app
}
expect_trampolines_called


# ptrace()

# the ptrace system call takes a request argument which can be set to 
# PTRACE_POKETEXT ... allowing the program calling ptrace() to 
# modify memory in a running process

# debuggers and tracers can use PTRACE_POKETEXT to write the int $3
# instruction into a program's memroy while it is running. This is how 
# breakpoints are set in programs.

# ptrace +PTRACE_POKETEXT + int $3 = ltrace

# ltrace works by
# 1) attaching to the running program with ptrace
# 2) locating the PLT of a program
# 3) using ptrace with PTRACE_POKETEXT to overwrite the assembly 
#    trampolines in the program's PLT entry for each library function 
#    with the int $3 instruction
# 4) resuming execution of the program

# ... and finally ltrace must replace the int $3 instruction it wrote 
# in the PLT with the original code, so that the program can be 
# resumed and execute correctly
# MY NOTE {
# some kind of tearDown() of ltrace I think
# 
# }







