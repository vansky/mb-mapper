import sys, argparse, operator, pandas as pd
argparser = argparse.ArgumentParser('''
Combines user-specified columns with user-specified functions in space-delimited data table.
''')
argparser.add_argument('-f', '--functions', dest='f', nargs='+', action='store', help='Functions to generate new columns by combining old ones. Format: -f col1,-,col2 col3,+,col4 -> col1-col2 col3+col4')
args, unknown = argparser.parse_known_args()

def function_parser(func_string):
    func_dict = {'+':operator.add,
                 '-':operator.sub,
                 '*':operator.mul,
                 '/':operator.truediv,
                 '%':operator.mod,
                 '^':operator.pow}
    return(func_dict[func_string])

data = pd.read_csv(sys.stdin, sep=' ', skipinitialspace=True)
for colpair in args.f:
    col1,op,col2 = colpair.split(',')
    if op in ('^'):
        data[str(col1)+str(op)+str(col2)] = function_parser(op)(data[col1],float(col2))
    else:
        data[str(col1)+str(op)+str(col2)] = function_parser(op)(data[col1],data[col2])
data.to_csv(sys.stdout, sep=' ', index=False, na_rep='nan')
