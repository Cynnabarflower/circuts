# import SpicePy modules

if __name__ == '__main__':
    import sys
    import netlist as ntl
    from netsolve import net_solve


    separator = sys.argv[1]
    arg = sys.argv[2]
    variables = []
    if len(sys.argv) > 3:
        variables = sys.argv[3:]
    arg = arg.strip().replace('%20', '\n')
#     arg = '''
# V1 1 0 sin(0 1 159k)
# R1 1 2 1
# C1 2 0 1m
# L1 2 0 1m
# .tran 1u 1m 0 0
# .backanno
# .end'''.strip()

    # read netlist
    net = ntl.Network(arg)

    # compute the circuit solution
    net_solve(net)

    # compute branch quantities
    net.branch_voltage()
    net.branch_current()
    net.branch_power()

    # print results
    for variable in variables:
        print(f'>{variable}<')
        m = net.print(message=1,variable=variable.strip())
        print(m)