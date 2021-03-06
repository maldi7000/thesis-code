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
#include <array>
#include <initializer_list>
#include <utility>
#include <chrono>

// root
#include "TFile.h"
#include "TTree.h"
#include "TBranch.h"

using namespace std;
using std::chrono::high_resolution_clock;
using namespace ROOT;

// /** enum for adhoc type handling*/
// enum Type {
//   b, /**< bool */
//   i, /**< int */
//   d, /**< double */
// };

/**
 * helper struct that holds the values of a line in a .dat file
 */
struct Line {
  /** constructor from vector. initializes values to empty vector then swaps val and values*/
  Line(std::vector<double>& val, bool t) : values{val}, truth(t) { ; }

  void Print();
  std::vector<double> values; /**< vector of doubles holding the values of a line */
  bool truth;
};

void Line::Print()
{
  for (double val: values) { cout << val << " "; }
  cout << truth << endl;
}

/**
 * small helper struct to keep the pointers of ROOT contained
 */
struct RootFile {

  /** constructor */
  RootFile(char* filename, std::string treename, std::initializer_list<std::string> bNames);
  RootFile(char* filename, std::string treename) : RootFile(filename, treename, {}) { ; }
  ~RootFile(); // { delete tree; delete file; } /**< destructor */

  void Write() { file->cd(); file->Write(); } //file->Close(); } /**< Write the contents to the root file. Close in destructor */
  // void Fill() { tree->Fill(); } /**< Fill the values into the tree */
  template<class T>
  void AddBranch(std::string name, T& var); /**< Add a branch in the ROOTfile */
  // void CreateBranches(const std::vector<Type>& types); /**< create a branch for each name and type */
  TFile* file;
  TTree* tree;
  std::vector<std::string> branchNames;
  size_t nBranches;
};

RootFile::~RootFile()
{
  Write(); // write file before closing and deleting the tree
  if(tree) delete tree; // delete tree before closing root file (seg fault else)
  file->Close();
  if(file) delete file;
}

RootFile::RootFile(char* filename, std::string treename, std::initializer_list<std::string> bNames) :
  branchNames{bNames}, nBranches(bNames.size())
{
  file = new TFile(filename, "recreate");
  tree = new TTree(treename.c_str(), "dat file data");
}

template<class T>
void RootFile::AddBranch(std::string name, T& var)
{
  tree->Branch(name.c_str(), &var);
  branchNames.push_back(name); nBranches++;
}

/**
 * create a Line object from a raw string
 */
Line convertStringToLine(std::string rawline)
{
  stringstream ss{rawline};
  vector<double> rawvals;
  for(;;){
    double d;
    ss >> d;
    if(!ss) break;
    rawvals.push_back(d);
  }

  bool truth = rawvals.back();
  rawvals.pop_back();

  return Line(rawvals, truth);
}

/** read nLines (or until EOF) from infile and return vector of Lines */
std::vector<Line> readNLines(ifstream& infile, unsigned int nLines)
{
  vector<Line> lines{};
  unsigned int lCtr{};
  while(!infile.eof() && lCtr < nLines) {
    string s;
    getline(infile, s);
    // cout << s << endl;
    if(!s.empty()) lines.push_back(convertStringToLine(s));
    // lines.back().Print();
    lCtr++;
  }
  return lines;
}

/**
 * create the .root file from the
 * @param: filename, dat file name
 * @param: outfilename, filename of the output file
 */
void convertToRootFile(char* filename, char* outfilename)
{
  ifstream infile(filename, ifstream::in);
  // int nCols = getNColumns(infile);

  RootFile rootfile(outfilename,"testtree");
  std::array<std::vector<double>,9> branches;
  std::vector<int> truth;
  for(size_t i = 0; i < branches.size(); ++i) {
    stringstream name{}; name << "Z" << i;
    rootfile.AddBranch(name.str().c_str(), branches[i]);
  }
  rootfile.AddBranch("truth", truth);


  std::vector<Line> lineValues{};
  static size_t linnr = 0;
  high_resolution_clock::time_point start = high_resolution_clock::now(); // measure time
  for(;;) {
    lineValues = readNLines(infile, 100); // COULDDO: increase this number (100 - 1000 seems to be optimum)
    if(lineValues.empty()) break;
    linnr += lineValues.size();

    // clear vectors and arrays before readin
    std::array<std::vector<double>,9> emptyBranches{};
    branches.swap(emptyBranches);
    truth.clear();

    for(Line line: lineValues) {
      for(size_t i = 0; i < branches.size(); ++i) {
        branches[i].push_back(line.values[i]);
      }
      truth.push_back(line.truth);
    }

    rootfile.tree->Fill();
  }
  cout << "read " << linnr << " lines from file: " << filename << endl;

  infile.close();
  rootfile.Write();
  high_resolution_clock::time_point end = high_resolution_clock::now();
  cout << "duration: " << chrono::duration_cast<chrono::microseconds>(end - start).count() / 1000. << " ms" << endl;
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
