"""
"""


def inspect_int(v):
    print(type(v))
    print(v)
    print(v.type)
    print(v.address)


def inspect_vector(v):
    print(v)
    impl = v['_M_impl']
    print(impl)
    print(impl['_M_start'])
    print(impl['_M_finish'])


def main():
    import gdb
    
    # containing the python directory (gdb.py)
    print(gdb.PYTHONDIR)
        
    # breakpoints are python objects
    print(gdb.breakpoints())
    
    # access gdb value
    # in this case, i is an instance of an instantiated struct template
    i = gdb.parse_and_eval('i')
    inspect_int(i['t'])
    inspect_vector(i['store'])

