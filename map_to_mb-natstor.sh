#!/bin/bash

naturalstories_dir=X

## Required paths
### modelblocks location
mb_location=../modelblocks-release

### unigram scripts (e.g., from replication repo, SCIL 2019)
unigram_training_script=scripts/calcunigram.py
unigram_insertion_script=scripts/insertunigrams.py
roll_removal_script=scripts/removerolled.py
### unigram training data
unigram_data=wikitext-103/wiki.train.tokens
### RT data from RT corpus
rt_data=processed_RTs.tsv

## Generated filenames
### column of tokenized input words
natstor_words=natstor.toks
### all complexity measures combined
df_full=naturalstories.full.results
### complexity combined with input words
df_fullwords=naturalstories.results.fullwords



python model_paster.py ${df_full} "$@"

mkdir genmodel

### make %linetoks
cat ${naturalstories_dir}/parses/penn/all-parses.txt.penn | perl ${mb_location}/resource-linetrees/scripts/editabletrees2linetrees.pl > genmodel/naturalstories.penn.linetrees  

cat genmodel/naturalstories.penn.linetrees | python ${mb_location}/resource-naturalstories/scripts/penn2sents.py | sed 's/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;s/peaked/peeked/g;' > genmodel/naturalstories.linetoks  


### combine with measures
echo 'words' > ${natstor_words}
sed 's/ /\n/g' genmodel/naturalstories.linetoks >> ${natstor_words}
paste -d' ' ${natstor_words} ${df_full} > ${df_full}.words
python ${unigram_training_script} < ${unigram_data} > unigrams.txt
python ${unigram_insertion_script} unigrams.txt ${df_full}.words > ${df_full}.unigrams

### make genmodel/naturalstories.mfields.itemmeasures
cat ${naturalstories_dir}/naturalstories_RTS/all_stories.tok | sed 's/\t/ /g;s/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;s/peaked/peeked/g;' | python ${mb_location}/resource-rt/scripts/toks2sents.py genmodel/naturalstories.linetoks > genmodel/naturalstories.lineitems  

paste -d' ' <(cat ${naturalstories_dir}/naturalstories_RTS/all_stories.tok | sed 's/\t/ /g;s/peaked/peeked/g') <(cat genmodel/naturalstories.lineitems | python ${mb_location}/resource-rt/scripts/sents2sentids.py | cut -d' ' -f 2-) \  
    <(cat ${naturalstories}/naturalstories_RTS/all_stories.tok | sed 's/\t/ /g;' | awk -f ${mb_location}/resource-rt/scripts/filter_cols.awk -v cols=item - | python ${mb_location}/resource-rt/scripts/rename_cols.py item docid) > genmodel/naturalstories.mfields.itemmeasures  
rm genmodel/naturalstories.lineitems  

### combine with RTs
paste -d' ' ${natstor_words} <(cut -d' ' -f2- ${df_full}.unigrams) | python ${mb_location}/resource-rt/scripts/roll_toks.py <(sed 's/(/-LRB-/g;s/)/-RRB-/g;' genmodel/naturalstories.mfields.itemmeasures) sentid sentpos > ${df_full}.models

cut -d' ' -f2- ${df_full}.models  | paste -d' ' genmodel/naturalstories.mfields.itemmeasures - > ${df_full}.models_mergable

python ${mb_location}/resource-naturalstories/scripts/merge_natstor.py <(cat ${naturalstories_dir}/naturalstories_RTS/processed_RTs.tsv | sed 's/\t/ /g;s/peaked/peeked/g;' | python ${mb_location}/resource-rt/scripts/rename_cols.py WorkerId subject RT fdur) ${df_full}.models_mergable | sed 's/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;' | python ${mb_location}/resource-rt/scripts/rename_cols.py item docid > ${df_full}.models_rt

python ${mb_location}/resource-rt/scripts/rm_unfix_items.py < ${df_full}.models_rt | python ${mb_location}/resource-rt/scripts/rm_na_items.py | grep -v '<unk>'> ${df_full}.models_rt_filtered

python ${roll_removal_script} < ${df_full}.models_rt_filtered > ${df_full}.models_rt_filtered_noroll 

mkdir rdata  
mkdir results  
