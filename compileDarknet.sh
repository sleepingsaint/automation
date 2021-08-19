#! /usr/bin/bash

echo "Cloning the darknet..."
git clone https://github.com/AlexeyAB/darknet 
cd darknet

echo "Updating the makefile to compile with gpu and opencv..."
sed -i 's/CUDNN=0/CUDNN=1/' Makefile
sed -i 's/GPU=0/GPU=1/' Makefile
sed -i 's/OPENCV=0/OPENCV=1/' Makefile

echo "Compiling the darknet"
make
