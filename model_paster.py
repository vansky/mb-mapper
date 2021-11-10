''' python model_paster.py OUTPUT [FILE1 FILE2 ..]


'''

import pandas
import sys
import numpy as np

assert len(sys.argv) > 3, "Need an output and multiple model outputs to merge"

SEP = ' '
GOOD_COLS = ('(surp)|(entropy)|(entred)|(conf)') 
OUTPUT_NAME = sys.argv[1] #'naturalstories.full.results'
output = pandas.read_csv(sys.argv[2],sep=SEP,quoting=3,dtype={"time":np.int32,"word":'str',"sentid":np.int32,"sentpos":np.int32,"wlen":np.int32})

# Create initial dataframe that lacks the columns of interest but has sentpos, wlen, etc
output = output.drop(output.filter(regex=GOOD_COLS).columns,errors="ignore",axis=1)

dfs = []

for fname in sys.argv[2:]:
    df = pandas.read_csv(fname,sep=SEP,quoting=3)
    df = df.filter(regex=GOOD_COLS)
    df = df.add_prefix('.'.join(fname.split('/')[-1].split('.')[:-1])+'_')
    dfs.append(df)

output = output.join(dfs)
output.to_csv(OUTPUT_NAME,sep=SEP,index=False)
