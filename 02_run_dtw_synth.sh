#!/bin/bash

if test "$#" -ne 4; then
    echo "################################"
    echo "Usage:"
    echo "./02_run_dtw_synth.sh <data_dir> <synth_wav> <ref_natural_wav> <samp_freq>"
    echo ""
    echo "Give your data dir contains synthesis wav and original natural wavs <data_dir>: test_data/test_wav"
    echo "Give your synthesis wav dir name <synth_wav>: synth_wav"
    echo "Give your original natural wav dir name <ref_natural_wav>: origin_wav"
    echo "Give your wav sampling frequency <samp_freq>: 48000"
    echo "################################"
    exit 1
fi


current_working_dir=$(pwd)
script_dir=${current_working_dir}/tools/scripts
current_dir=$1
synth_wav=${current_dir}/$2
nat_wav=${current_dir}/$3
samp_freq=$4
synth_feats=${current_dir}/$2_feats
nat_feats=${current_dir}/$3_feats

mkdir -p ${synth_feats}
mkdir -p ${nat_feats}

### extract features using WORLD ###
echo "Prepare acoustic features using WORLD vocoder..."
python ${script_dir}/extract_features_WORLD.py ${synth_wav} ${synth_feats} ${samp_freq}
python ${script_dir}/extract_features_WORLD.py ${nat_wav} ${nat_feats} ${samp_freq}

### gen compare list ###
synthNum=`ls -l ${synth_wav} | grep "^-" | wc -l`
natNum=`ls -l ${nat_wav}|grep "^-"|wc -l`
if [ $synthNum -ne $natNum ] ; then
    echo "The number of test wavs and ref wavs are not equal."
    exit 1
fi
ls ${synth_wav} >${current_dir}/synth.scp
sed -i 's/\.wav//g' ${current_dir}/synth.scp
ls ${nat_wav} >${current_dir}/nat.scp
sed -i 's/\.wav//g' ${current_dir}/nat.scp
paste -d "+" ${current_dir}/synth.scp ${current_dir}/nat.scp >${current_dir}/corpus.scp

### run dtw_synth
mkdir -p ${current_dir}/out
cat ${current_dir}/corpus.scp | xargs bin/dtw_synth ${nat_feats} ${synth_feats} ${current_dir}/out

