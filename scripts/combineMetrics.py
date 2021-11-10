import sys, argparse, operator, pandas as pd
argparser = argparse.ArgumentParser('''
Combines user-specified columns in space-delimited data table.
''')
argparser.add_argument('-f', '--columns', dest='f', nargs='+', action='store', help='Columns to combine. Format: -f col1,-,col2 col3,+,col4 -> col1-col2 col3+col4')
args, unknown = argparser.parse_known_args()

def function_parser(func_string):
    func_dict = {'+':operator.add,
                 '-':operator.sub,
                 '*':operator.mul,
                 '/':operator.truediv,
                 '%':operator.mod}
    return(func_dict[func_string])

data = pd.read_csv(sys.stdin, sep=' ', skipinitialspace=True)
for colpair in args.f:
    col1,op,col2 = colpair.split(',')
    data[str(col1)+str(op)+str(col2)] = function_parser(op)(data[col1],data[col2])
data.to_csv(sys.stdout, sep=' ', index=False, na_rep='nan')
