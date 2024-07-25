#!/bin/bash

export USER=workspace

catkin_make -C /workspace/catkin_ws ;
source /workspace/catkin_ws/devel/setup.bash ;

wait;

roslaunch vins vio.launch 

wait;