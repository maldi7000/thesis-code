# this is a very simple makefile that is primarly only here to be able to compile directly from emacs

CC=g++
CXXFLAGS=-std=c++11 -Wall
INCL=-I/home/Applications/root/include
LIB=$(shell root-config --libs) # add all root libraries. CAUTION! this gets the environment variables from the shell in which emacs was started!

default: root2dat

root2dat: samples_root2dat.cc
	$(CC) $(LIB) $(INCL) $(CXXFLAGS) samples_root2dat.cc
