import sys, argparse, pandas as pd
argparser = argparse.ArgumentParser('''
Diffs user-specified columns in space-delimited data table.
''')
argparser.add_argument('-c', '--columns', dest='c', nargs='+', action='store', help='Columns to diff. Format: -c col1,col2+col3,col4 -> col1-col2 col3-col4')
args, unknown = argparser.parse_known_args()
args.n = int(args.n[0])

data = pd.read_csv(sys.stdin, sep=' ', skipinitialspace=True)
for colpair in args.c:
    col1,col2 = colpair.split(',')
    data['diff:'+str(col1)+'_'+str(col2)] = data[col1] - data[col2]
data.to_csv(sys.stdout, sep=' ', index=False, na_rep='nan')
