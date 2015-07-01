///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// program shall take a .dat file and put all values into a .root file                                               //
// every column in the dat file will get its own root file                                                           //
// the names of the branches are read from the first line in the .dat file                                           //
// if there are no strings in the first line of the .dat file, unique but otherwise undescriptive names will be used //
//                                                                                                                   //
// by Thomas Madlener, 2015                                                                                          //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// stl
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <initializer_list>
#include <utility>

// root
#include "TFile.h"
#include "TTree.h"
#include "TBranch.h"

using namespace std;
using namespace ROOT;

/**
 * helper struct that holds the values of a line in a .dat file
 */
struct Line {
  /** constructor from vector. initializes values to empty vector then swaps val and values*/
  Line(std::vector<double>& val) : values{} { std::swap(val,values); }

  std::vector<double> values; /**< vector of doubles holding the values of a line */
};

/**
 * small helper struct to keep the pointers of ROOT contained
 */
struct RootFile {

  /** constructor */
  RootFile(char* filename, std::string treename, std::initializer_list<std::string> bNames);
  ~RootFile() { delete tree; delete file; } /**< destructor */

  void Close() { file->cd(); file->Write(); file->Close(); } /**< Close the root file properly. FIXME; segfault at the moment */
  // void Fill() { tree->Fill(); } /**< Fill the values into the tree */
  void CreateBranches(); /**< Create the branches in the root file */
  TFile* file;
  TTree* tree;
  std::vector<std::string> branchNames;
  size_t nBranches;
};

RootFile::RootFile(char* filename, std::string treename, std::initializer_list<std::string> bNames) :
  branchNames{bNames}, nBranches(bNames.size())
{
  file = new TFile(filename, "recreate");
  tree = new TTree(treename.c_str(), "dat file data");
}

void RootFile::CreateBranches()
{
  // TODO
}

/**
 * split string and return vector of substrings
 */
const std::vector<string> splitString(std::string str, char delim = ' ')
{
  std::vector<string> substrs;
  std::stringstream ss{str};
  std::string tmp;
  while(std::getline(ss,tmp,delim)) substrs.push_back(tmp);
  return substrs;
}

/**
 * get the number of columns from the first line in the .dat file
 * @param infile, ifstream to input .datfile
 * returns the number of columns in the .dat file and sets the ifstream to the position prior to the first uncommented line
 */
int getNColumns(ifstream& infile)
{
  streampos prelinepos;
  string firstline;
  do {
    prelinepos = infile.tellg(); // get position before getline
    getline(infile, firstline);
    cout << firstline << endl;
  } while(firstline.substr(0,1) == "#");

  infile.seekg(prelinepos); // 'putback' line to ifstream
  
  return splitString(firstline).size();
}


/**
 * create the .root file from the
 * @param: filename, dat file name
 * @param: outfilename, filename of the output file
 */
void convertToRootFile(char* filename, char* outfilename)
{
  ifstream infile(filename, ifstream::in);
  int nCols = getNColumns(infile);
  cout << "columns in file: " << nCols << endl;
  
  RootFile rootfile(outfilename,"testtree",{});

  // infile.close();
  // rootfile.Close();
}

#ifndef __CINT__
/**
 * main routine. simply calls above defined method with passed command-line arguments
 */
int main(int argc, char* argv[])
{
  if(argc != 3) {
    cout << "please provide a .dat file and an output file name" << endl;
    return -1;
  }

  convertToRootFile(argv[1], argv[2]);
  return 0;
}

#endif
