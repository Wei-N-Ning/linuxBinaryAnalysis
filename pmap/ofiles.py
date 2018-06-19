# -*- coding: utf-8 -*-

import re
import subprocess
import shlex


class OFilesCollector(object):
    
    pmap_exe = '/usr/bin/pmap'
    readelf_exe = '/usr/bin/readelf'
    gcc_command_line_section = '.GCC.command.line'.replace('.', '\.')

    def __init__(self, pid):
        self.pid = pid
        self._so_files = set()
        self._o_files = set()

    def _iter_so_files(self):
        output = subprocess.check_output(shlex.split('{} -x -p {}'.format(self.pmap_exe, self.pid)))
        for l in output.split('\n'):
            _ = re.search(r'(/\S+)+\.so\S*', l)
            if not _:
                continue
            so_file = _.group()
            if so_file in self._so_files:
                continue
            self._so_files.add(so_file)
            yield so_file
    
    def _has_gcc_command_line(self, so_file):
        output = subprocess.check_output(shlex.split('{} -S {}'.format(self.readelf_exe, so_file)))
        for l in output.split('\n'):
            if re.search(r'\[\d+\]\s+({})'.format(self.gcc_command_line_section), l):
                return True
        return False
    
    def _collect_o_files(self, so_file):
        output = subprocess.check_output(shlex.split('{} -p {} {}'.format(self.readelf_exe, self.gcc_command_line_section, so_file)))
        for l in output.split('\n'):
            _ = re.search(r'(/\S+)+\.o\S*', l)
            if not _:
                continue
            o_file = _.group()
            if o_file in self._o_files:
                continue
            self._o_files.add(o_file)

    def run(self):
        for so_file in self._iter_so_files():
            pass
        print('found {} .so files'.format(len(self._so_files)))
        count = 0
        for so_file in sorted(self._so_files):
            if self._has_gcc_command_line(so_file):
                self._collect_o_files(so_file)
            count += 1
            if count and count % 10 == 0:
                print('{}/{}'.format(count, len(self._so_files)))
        print('found {} .o files'.format(len(self._o_files)))
        paths = sorted(self._o_files)
        if len(self._o_files) > 200:
            with open('/tmp/out.txt', 'w') as fp:
                fp.write('\n'.join(paths))
            print('cat /tmp/out.txt for details')
            return
        for _ in paths:
            print(_)
        return



if __name__ == '__main__':
    import sys
    if len(sys.argv) < 2:
        raise RuntimeError('missing pid!')
    OFilesCollector(sys.argv[1]).run()


