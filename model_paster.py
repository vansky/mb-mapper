''' python model_paster.py [FILE1 FILE2 ..]


'''

import pandas
import sys

assert len(sys.argv) > 2, "Need multiple model outputs to merge"

SEP = ' '
GOOD_COLS = ('(surp)|(entropy)|(entred)|(conf)') 
OUTPUT_NAME = 'naturalstories.full.results'
output = pandas.read_csv(sys.argv[1],sep=SEP)

# Create initial dataframe that lacks the columns of interest but has sentpos, wlen, etc
output = output.drop(output.filter(regex=GOOD_COLS).columns,errors="ignore",axis=1)

dfs = []


for fname in sys.argv[1:]:
    df = pandas.read_csv(fname,sep=SEP)
    df = df.filter(regex=GOOD_COLS)
    df = df.add_prefix('.'.join(fname.split('/')[-1].split('.')[:-1])+'_')
    dfs.append(df)

output = output.join(dfs)
output.to_csv(OUTPUT_NAME,sep=SEP,index=False)
