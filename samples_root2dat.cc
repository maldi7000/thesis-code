///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This program shall take .root file with training samples contained in it and write them to a .dat file such that they can //
// then be read into MATLAB from that.                                                                                       //
//                                                                                                                           //
// by Thomas Madlener                                                                                                        //
//                                                                                                                           //
// start of dev: 25.05.2015                                                                                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <array>

// ROOT
#include "TFile.h"
#include "TTree.h"
#include "TBranch.h"


using namespace std;

/** name of the TTree in the root file*/
const std::string treename = "ThreeHitSamplesTree";
/** name of the branches in the TTree */
const std::vector<std::string> branchnames = { "hit1X", "hit1Y", "hit1Z", "hit2X", "hit2Y", "hit2Z",
                                               "hit3X", "hit3Y", "hit3Z", "signal" };

/** number of all branches containing a vector<double> (i.e. all, but the signal branch) */
const size_t nbranches = 9;

/** helper struct that can be used to get the values from the root file */
struct RootBranches {
  /** empty ctor initializes all pointers to NULL */
  RootBranches() : signal(NULL) {
    for(vector<double>*& vec : positions) vec = NULL;
  }
  
  std::array<std::vector<double>*, nbranches> positions; /**< array of vector of doubles that hold the position branches*/
  std::vector<bool>* signal; /**< vector of bools for the signal branch */
};

/**
 * set the branch adresses for the first time
 * @param: tree, the TTree containing the data
 * @param: branches, the RootBranches helper struct that will be set as the addresses of the branches
 */
   
void setBranchAddresses(TTree* tree, RootBranches& branches)
{
  for(size_t i = 0; i < nbranches; ++i) {
    if(tree->SetBranchAddress(branchnames[i].c_str(), &branches.positions[i]) != 0) {
      cout << "ERROR: while trying to set branch address for positions" << endl;
    }
  }

  if(tree->SetBranchAddress(branchnames.back().c_str(), &branches.signal) != 0) {
    cout << "ERROR: while trying to set branch address for signal" << endl;
  }
}

/**
 * get the data from the event onto the RootBranches, from where they can than be written to the file
 * @param: tree, the TTree containing the data
 * @param: branches, the RootBranches helper struct to which the data will be transfered
 * @param: event, the event number for which the data shall be obtained 
 */
void getEvent(TTree* tree, RootBranches& branches, unsigned event)
{
  tree->GetEvent(event);
}

/**
 * create the .dat file from the
 * @param: filename, root file name
 * @param: outfilename, filename of the output file
 */
void convertToDatFile(char* filename, char* outfilename)
{
  TFile* infile = TFile::Open(filename);
  TTree* tree = (TTree*) infile->Get(treename.c_str());
  RootBranches branches;

  setBranchAddresses(tree, branches);

  ofstream outfile(outfilename, ofstream::out);
}

#ifndef __CINT__
/**
 * main routine
 * first command line argument is root file, second is outputfile
 */
int main(int argc, char* argv[])
{
  convertToDatFile(argv[1], argv[2]);
  
  return 0;
}
#endif
