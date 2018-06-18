#!/usr/bin/env python

import os
import re
import subprocess
import shlex


RED = '\033[0;31m'
NC = '\033[0m' # No Color
RED_T = '\033[0;31m{}\033[0m'


class RLDD(object):
    
    ldd = '/usr/bin/ldd'
    
    NOT_FOUND = 'XXXX'

    def __init__(self):
        self.lib_paths = dict()
        self.not_founds = set()
        self.dep_graph = dict()

    def call_ldd(self, bin_path):
        p = subprocess.Popen(
            shlex.split('{} {}'.format(self.ldd, bin_path)), 
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        assert 0 == p.wait(), p.stderr.read()
        return p.stdout.readlines()
    
    def parse_line(self, line):
        line = line.strip()
        result = re.search('(.+) => (.+)$', line)
        if not result:
            return '', ''
        lib_name, lib_path = result.groups()
        lib_name = lib_name.replace('\t', '').strip()
        lib_path = lib_path.split('(')[0].strip()
        if len(lib_path) < 4:
            return '', ''
        if 'not found' in lib_path:
            return lib_name, self.NOT_FOUND
        return lib_name, lib_path
    
    def _process(self, bin_path, bin_name=''):
        output = self.call_ldd(bin_path)
        for line in output:
            lib_name, lib_path = self.parse_line(line)
            if not lib_name:
                continue
            if lib_name in self.lib_paths:
                continue
            self.lib_paths[lib_name] = lib_path
            self.dep_graph[(lib_name, lib_path)] = (bin_name, bin_path)
            if lib_path == self.NOT_FOUND:
                self.not_founds.add(lib_name)
            else:
                assert os.path.isfile(lib_path), '({})'.format(lib_path)
                self._process(lib_path, lib_name)
    
    def prt(self, lib_name, lib_path, indent):
        if lib_path == self.NOT_FOUND:
            print(RED_T.format(indent + lib_name))
        else:
            print(indent + lib_name + '  ' + lib_path)

    def print_dep(self, lib_name, lib_path, indent_depth):
        self.prt(lib_name, lib_path, '  ' * indent_depth)
        record = (lib_name, lib_path)
        dep = self.dep_graph.get(record)
        if dep:
            self.print_dep(dep[0], dep[1], indent_depth + 1)

    def process(self, bin_path):
        self._process(bin_path)
        for lib_name in self.not_founds:
            self.print_dep(lib_name, self.NOT_FOUND, 0)
            print('----\n')


if __name__ == '__main__':
    import sys
    assert len(sys.argv) > 1
    RLDD().process(sys.argv[1])

