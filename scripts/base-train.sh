#!/bin/bash
# bash ./scripts/base-train.sh cifar10 ResNet110 E300 L1 256 -1
echo script name: $0
echo $# arguments
if [ "$#" -ne 6 ] ;then
  echo "Input illegal number of parameters " $#
  echo "Need 6 parameters for the dataset and the-model-name and epochs and LR and the-batch-size and the-random-seed"
  exit 1
fi
if [ "$TORCH_HOME" = "" ]; then
  echo "Must set TORCH_HOME envoriment variable for data dir saving"
  exit 1
else
  echo "TORCH_HOME : $TORCH_HOME"
fi

dataset=$1
model=$2
epoch=$3
LR=$4
batch=$5
rseed=$6


PY_C="./env/bin/python"
if [ ! -f ${PY_C} ]; then
  echo "Local Run with Python: "`which python`
  PY_C="python"
  SAVE_ROOT="./output"
else
  echo "Cluster Run with Python: "${PY_C}
  SAVE_ROOT="./hadoop-data/SearchCheckpoints"
fi

save_dir=${SAVE_ROOT}/basic/${dataset}/${model}-${epoch}-${LR}-${batch}

${PY_C} --version

${PY_C} ./exps/basic-main.py --dataset ${dataset} \
	--data_path $TORCH_HOME/cifar.python \
	--model_config ./configs/archs/CIFAR-${model}.config \
	--optim_config ./configs/opts/CIFAR-${epoch}-W5-${LR}-COS.config \
	--procedure    basic \
	--save_dir     ${save_dir} \
	--cutout_length -1 \
	--batch_size  ${batch} --rand_seed ${rseed} --workers 4 \
	--eval_frequency 1 --print_freq 100 --print_freq_eval 200
