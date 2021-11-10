import sys, argparse, operator, pandas as pd
argparser = argparse.ArgumentParser('''
Combines user-specified columns in space-delimited data table.
''')
argparser.add_argument('-c', '--columns', dest='c', nargs='+', action='store', help='Columns to combine. Format: -c col1,col2 col3,col4 (with -f=-)-> col1-col2 col3-col4')
argparser.add_argument('-f', '--function', dest='f', action='store', default='-', help='Function with which to combine columns.')
args, unknown = argparser.parse_known_args()

def function_parser(func_string):
    func_dict = {'+':operator.add,
                 '-':operator.sub,
                 '*':operator.mul,
                 '/':operator.truediv,
                 '%':operator.mod}
    return(func_dict[func_string])

data = pd.read_csv(sys.stdin, sep=' ', skipinitialspace=True)
for colpair in args.c:
    col1,col2 = colpair.split(',')
    data[str(col1)+str(args.f)+str(col2)] = function_parser(args.f)(data[col1],data[col2])
data.to_csv(sys.stdout, sep=' ', index=False, na_rep='nan')
