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

export CAPTURE_SCREEN=false;
export LOG_DATA=true;


#region Run each dataset with VINS ------------------------------------------------------------------------------------

wait;

export EPOC_DIR=$EPOC_DIR;
export DATASET_LOCATION=$DATASET_LOCATION;
export ROS_PKG_DIR=$PACKAGE_DIR;
export EXP_NAME=eee_01;
export CAPTURE_SCREEN=$CAPTURE_SCREEN;
export LOG_DATA=$LOG_DATA;
export LOG_DUR=450;
export FUSE_UWB=0;
export FUSE_VIS=1;
export UWB_BIAS=0.75;
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

export BA_LOOP_LOG_DIR=/home/$USER;
if $LOG_DATA
then
export BA_LOOP_LOG_DIR=$EXP_OUTPUT_DIR;
fi
echo BA LOG DIR: $BA_LOOP_LOG_DIR;

mkdir -p $EXP_OUTPUT_DIR/ ;
cp -R $ROS_PKG_DIR/../config $EXP_OUTPUT_DIR;
cp -R $ROS_PKG_DIR/launch $EXP_OUTPUT_DIR;
roslaunch vins run_ntuviral.launch log_dir:=$EXP_OUTPUT_DIR \
log_dir:=$VIRAL_OUTPUT_DIR \
autorun:=true \
bag_file:=$DATASET_LOCATION/$EXP_NAME/$EXP_NAME.bag \
& \

if $CAPTURE_SCREEN
then
echo CAPTURING SCREEN ON;
sleep 1;
ffmpeg -video_size 1920x1080 -framerate 1 -f x11grab -i :0.0+1920,0 \
-loglevel quiet -t $LOG_DUR -y $EXP_OUTPUT_DIR/$EXP_NAME.mp4 \
& \
else
echo CAPTURING SCREEN OFF;
sleep 1;
fi

if $LOG_DATA
then
echo LOGGING ON;
sleep 5;
rosparam dump $EXP_OUTPUT_DIR/allparams.yaml;
timeout $LOG_DUR rostopic echo -p --nostr --noarr /vins_estimator/imu_propagate \
> $EXP_OUTPUT_DIR/vio_odom.csv  \
& \
timeout $LOG_DUR rostopic echo -p --nostr --noarr /vins_estimator/odometry \
> $EXP_OUTPUT_DIR/opt_odom.csv \
& \
timeout $LOG_DUR rostopic echo -p --nostr --noarr /leica/pose/relative \
> $EXP_OUTPUT_DIR/leica_pose.csv \
& \
timeout $LOG_DUR rostopic echo -p --nostr --noarr /dji_sdk/imu \
> $EXP_OUTPUT_DIR/dji_sdk_imu.csv \
& \
timeout $LOG_DUR rostopic echo -p --nostr --noarr /imu/imu \
> $EXP_OUTPUT_DIR/vn100_imu.csv \
;
else
echo LOGGING OFF;
sleep $LOG_DUR;
fi

wait;
# poweroff;

#endregion ## Poweroff ------------------------------------------------------------------------------------------------