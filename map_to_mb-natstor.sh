#!/bin/bash
## Usage: map_to_mb.sh FILE1 FILE2 FILE3

naturalstories_dir=natstor
scripts_dir=../replications/vanschijndel_linzen-2019-scil

spillover_cols="wlen fixedunigram"
combine_cols="model1_surp,-,model2_surp"

## Required paths
### modelblocks location
mb_location=../modelblocks-release

### unigram scripts (e.g., from replication repo, SCIL 2019)
unigram_training_script=${scripts_dir}/scripts/calcunigram.py
unigram_insertion_script=${scripts_dir}/scripts/insertunigrams.py
roll_removal_script=${scripts_dir}/scripts/removerolled.py
### unigram training data
unigram_data=wikitext-103/wiki.train.tokens
### RT data from RT corpus
rt_data=processed_RTs.tsv

## Generated filenames
### column of tokenized input words
natstor_words=genmodel/natstor.toks
### all complexity measures combined
df_full=genmodel/naturalstories.full.results
### unigram file
unigram_file=genmodel/unigram.toks

mkdir genmodel

echo "Combine measures"
python model_paster.py ${df_full} "$@"

echo "Make linetoks"
### make %linetoks
cat ${naturalstories_dir}/parses/penn/all-parses.txt.penn | perl ${mb_location}/resource-linetrees/scripts/editabletrees2linetrees.pl > genmodel/naturalstories.penn.linetrees  

cat genmodel/naturalstories.penn.linetrees | python ${mb_location}/resource-naturalstories/scripts/penn2sents.py | sed 's/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;s/peaked/peeked/g;' > genmodel/naturalstories.linetoks  


### combine with measures
echo "Combine words and measures"
echo 'word' > ${natstor_words}
sed 's/ /\n/g' genmodel/naturalstories.linetoks >> ${natstor_words}
paste -d' ' ${natstor_words} ${df_full} > ${df_full}.words
python ${unigram_training_script} < ${unigram_data} > ${unigram_file}
python ${unigram_insertion_script} ${unigram_file} ${df_full}.words > ${df_full}.unigrams

echo "Making mfields"
### make genmodel/naturalstories.mfields.itemmeasures
cat ${naturalstories_dir}/naturalstories_RTS/all_stories.tok | sed 's/\t/ /g;s/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;s/peaked/peeked/g;' | python ${mb_location}/resource-rt/scripts/toks2sents.py genmodel/naturalstories.linetoks > genmodel/naturalstories.lineitems  

echo "  Part 2"
paste -d' ' <(cat ${naturalstories_dir}/naturalstories_RTS/all_stories.tok | sed 's/\t/ /g;s/peaked/peeked/g') <(cat genmodel/naturalstories.lineitems | python ${mb_location}/resource-rt/scripts/sents2sentids.py | cut -d' ' -f 2-) | paste -d' ' - <(cat ${naturalstories_dir}/naturalstories_RTS/all_stories.tok | sed 's/\t/ /g;' | awk -f ${mb_location}/resource-rt/scripts/filter_cols.awk -v cols=item - | python ${mb_location}/resource-rt/scripts/rename_cols.py item docid) > genmodel/naturalstories.mfields.itemmeasures  
#rm genmodel/naturalstories.lineitems  

echo "Combine with RTs"
### combine with RTs
paste -d' ' ${natstor_words} <(python ${mb_location}/resource-rt/scripts/filter_cols.py -x 'word' < ${df_full}.unigrams) | python ${mb_location}/resource-rt/scripts/roll_toks.py <(sed 's/(/-LRB-/g;s/)/-RRB-/g;' genmodel/naturalstories.mfields.itemmeasures) sentid sentpos > ${df_full}.models

cut -d' ' -f2- ${df_full}.models  | paste -d' ' genmodel/naturalstories.mfields.itemmeasures - > ${df_full}.models_mergable

python ${mb_location}/resource-naturalstories/scripts/merge_natstor.py <(cat ${naturalstories_dir}/naturalstories_RTS/processed_RTs.tsv | sed 's/\t/ /g;s/peaked/peeked/g;' | python ${mb_location}/resource-rt/scripts/rename_cols.py WorkerId subject RT fdur) ${df_full}.models_mergable | sed 's/``/'\''/g;s/'\'\''/'\''/g;s/(/-LRB-/g;s/)/-RRB-/g;' | python ${mb_location}/resource-rt/scripts/rename_cols.py item docid > ${df_full}.models_rt

python ${mb_location}/resource-rt/scripts/spilloverMetrics.py < ${df_full}.models_rt ${spillover_cols} | python ${mb_location}/resource-rt/scripts/rm_unfix_items.py | python ${mb_location}/resource-rt/scripts/rm_na_items.py | grep -v '<unk>' | python scripts/combineMetrics.py -f ${combine_cols} > ${df_full}.models_rt_filtered

python ${roll_removal_script} < ${df_full}.models_rt_filtered > ${df_full}.models_rt_filtered_noroll 

#mkdir rdata  
#mkdir results  
