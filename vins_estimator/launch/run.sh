#!/bin/bash

export USER=workspace

catkin_make -C /workspace/catkin_ws ;
source /workspace/catkin_ws/devel/setup.bash ;


# Get the current directory
CURR_DIR=$(pwd)
# Get the location of the viral package
roscd vins
PACKAGE_DIR=$(pwd)
# Return to the current dir, print the directions
cd $CURR_DIR
echo CURRENT DIR: $CURR_DIR
echo VINS DIR:    $PACKAGE_DIR

export EPOC_DIR=/workspace/result
export DATASET_LOCATION=/workspace/NTU_VIRAL_DATASET
# export DATASET_LOCATION=/media/$USER/myHPSSD/NTU_VIRAL

export LOG_DATA=false;

wait;

export EXP_NAME=eee_01;
export LOG_DUR=450;
export FUSE_VIS=1;
export ANC_ID_MAX=-1;

export BAG_DUR=$(rosbag info $DATASET_LOCATION/$EXP_NAME/$EXP_NAME.bag | grep 'duration' | sed 's/^.*(//' | sed 's/s)//');
let LOG_DUR=BAG_DUR+20

echo "BAG DURATION:" $BAG_DUR "=> LOG_DUR:" $LOG_DUR;

let ANC_MAX=ANC_ID_MAX+1

export EXP_OUTPUT_DIR=$EPOC_DIR/result_${EXP_NAME}_${ANC_MAX}anc;
if ((FUSE_VIS==1))
then
export EXP_OUTPUT_DIR=${EXP_OUTPUT_DIR}_vis;
fi
echo OUTPUT DIR: $EXP_OUTPUT_DIR;

mkdir -p $EXP_OUTPUT_DIR/ ;
cp -R $ROS_PKG_DIR/../config $EXP_OUTPUT_DIR;
cp -R $ROS_PKG_DIR/launch $EXP_OUTPUT_DIR;
roslaunch vins run_ntuviral.launch log_dir:=$EXP_OUTPUT_DIR \
log_dir:=$VIRAL_OUTPUT_DIR \
autorun:=true \
bag_file:=$DATASET_LOCATION/$EXP_NAME/$EXP_NAME.bag \
& \

wait;