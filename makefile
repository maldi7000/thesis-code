# this is a very simple makefile that is primarly only here to be able to compile directly from emacs
# NOTE: at the moment this does not compile unless a basf2 environment is set up! (it also does not run!)

CC=g++
CXXFLAGS=-std=c++11 -Wall -g
#INCL=-I/home/asehephy/root/include
#INCL=-I/home/Applications/root/include
INCL=-I$(shell root-config --incdir)
LIB=$(shell root-config --libs) # add all root libraries. CAUTION! this gets the environment variables from the shell in which emacs was started!



all: root2dat dat2root

root2dat: samples_root2dat.cc
	$(CC) $(LIB) $(INCL) $(CXXFLAGS) -o root2dat samples_root2dat.cc

dat2root: samples_dat2root.cc
	$(CC) $(LIB) $(INCL) $(CXXFLAGS) -o dat2root samples_dat2root.cc
