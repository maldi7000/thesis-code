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
using namespace ROOT;

/** name of the TTree in the root file*/
const std::string treename = "ThreeHitSamplesTree";
/** name of the branches in the TTree */
const std::vector<std::string> branchnames = { "hit1X", "hit1Y", "hit1Z", "hit2X", "hit2Y", "hit2Z",
                                               "hit3X", "hit3Y", "hit3Z", "truth", "vxdid1", "vxdid2", "vxdid3",
                                               "pT", "momentum", "charge", "pdg" };

/** number of all branches containing a vector<double> */
const size_t npositions = 9;

/** number of all branches containing a vector<short> */
const size_t nvxdids = 3;

/** number of all branches containing momentum/charge information */
const size_t nadditional = 3;

/** helper struct that can be used to get the values from the root file */
struct RootBranches {
  /** empty ctor initializes all pointers to NULL */
  RootBranches() : pdg(nullptr), signal(nullptr) {
    for(vector<double>*& vec : positions) vec = nullptr;
    for(vector<unsigned>*& vec: vxdids) vec = nullptr;
    for(vector<double>*& vec : additionalInfo) vec = nullptr;
  }

  std::array<std::vector<double>*, npositions> positions; /**< array of vector of doubles that hold the position branches */
  std::array<std::vector<unsigned>*, nvxdids> vxdids; /**< array of vector of doubles that hold the vxdid branches */
  std::array<std::vector<double>*, nadditional> additionalInfo; /**< array of vector of doubles that hold the additional Info Branches*/
  std::vector<int>* pdg; /**< vector holding the pdg */
  std::vector<bool>* signal; /**< vector of bools for the signal branch */
};

/**
 * set the branch adresses for the first time
 * @param: tree, the TTree containing the data
 * @param: branches, the RootBranches helper struct that will be set as the addresses of the branches
 */
void setBranchAddresses(TTree* tree, RootBranches& branches)
{
  for(size_t i = 0; i < npositions; ++i) {
    if(tree->SetBranchAddress(branchnames[i].c_str(), &branches.positions[i]) != 0) {
      cout << "ERROR: while trying to set branch address for positions! name: " << branchnames[i] << endl;
    }
  }

  if(tree->SetBranchAddress(branchnames[npositions].c_str(), &branches.signal) != 0) {
    cout << "ERROR: while trying to set branch address for signal" << endl;
  }

  for(size_t i = 0; i < nvxdids; ++i) {
    int setAd = tree->SetBranchAddress(branchnames[i + npositions + 1].c_str(), &branches.vxdids[i]);
    if( setAd != 0 && setAd != 1) {
      cout << "ERROR: while trying to set branch address for vxdids! name: " << branchnames[i + npositions + 1] << endl;
    }
  }

  for(size_t i=0; i < nadditional; ++i) {
    if(tree->SetBranchAddress(branchnames[i + npositions + 1 + nvxdids].c_str(), &branches.additionalInfo[i]) != 0) {
      cout << "ERROR: while trying to set branch address for additional info! name: " << branchnames[i+npositions+nvxdids+1] << endl;
    }
  }

  if(tree->SetBranchAddress(branchnames.back().c_str(), &branches.pdg) != 0) {
    cout << "ERROR: while trying to set branch address for pdg" << endl;
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
 * write a file header that hold some additional information
 * @param: outifle, outfile stream to which the header is written
 */
void writeFileHeader(ofstream& outfile)
{
  outfile << "# sp_1_x  sp_1_y  sp_1_z  sp_2_x  sp_2_y  sp_2_z  sp_3_x  sp_3_y  sp_3_z  vxdid1  vxdid2  vxdid3 pT momentum charge pdg signal" << endl;
}

/**
 * write the content of the RootBranches helper struct to the file
 * @param: branches, the RootBranches helper struct, which contents shall be written to a .dat file
 * @param: outfile, the outfile streamer to which the data shall be written
 */
void writeToFile(const RootBranches& branches, ofstream& outfile)
{
  for(size_t i = 0; i < branches.signal->size(); ++i) {
    for (size_t j = 0; j < npositions; ++j){
      outfile << branches.positions[j]->operator[](i) << " ";
    }
    for (size_t j = 0; j < nvxdids; ++j ) {
      outfile << branches.vxdids[j]->operator[](i) << " ";
    }
    for (size_t j = 0; j < nadditional; ++j) {
      outfile << branches.additionalInfo[j]->operator[](i) << " ";
    }
    outfile << branches.pdg->operator[](i) << " ";
    outfile << branches.signal->operator[](i) << endl;
  }
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
  // writeFileHeader(outfile); // ommit when using with MATLAB (TODO: find an easy (and fast) way in MATLAB to ignore comments)

  // get the data event-wise and write them to the file immediately
  for(unsigned i = 0; i < tree->GetEntries(); ++i) {
    getEvent(tree, branches, i);
    writeToFile(branches, outfile);
  }

  outfile.close();
}

#ifndef __CINT__
/**
 * main routine
 * first command line argument is root file, second is outputfile
 */
int main(int argc, char* argv[])
{
  if(argc != 3) {
    cout << "please provide a root file and an output file name!" << endl;
    return -1;
  }
  convertToDatFile(argv[1], argv[2]);

  return 0;
}
#endif
