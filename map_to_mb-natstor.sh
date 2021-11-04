#!/bin/bash

naturalstories_dir=X
#requires:
# naturalstories.linetoks
# processed_RTs.tsv

df_full=naturalstories.full.results

python model_paster.py ${df_full} "$@"

echo 'words' > natstor.toks
sed 's/ /\n/g' naturalstories.linetoks >> natstor.toks
