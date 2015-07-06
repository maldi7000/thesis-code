// small programm for standalone evaluation of samples given a TMVA method
//
// by Thomas Madlener, 2015

// stl
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <array>


// ROOT
#include "TMVA/Reader.h"
#include "TFile.h"
#include "TTree.h"

#include "TMVA/Factory.h"
#include "TMVA/Tools.h"
#include "TMVA/Config.h"
#include "TPluginManager.h"

// ROOT toolbox
#include "RootToolBox/RootFileData.hpp"
#include "RootToolBox/RootTreeData.hpp"

using namespace std;
using namespace ROOT;
using namespace RootToolBox;



/**
 * load the FastBDT plugin (copied from framework)
 */
void loadPlugins(const std::string& name)
{
  std::string base = "TMVA@@MethodBase";
  std::string regexp1 = std::string(".*_") + name + std::string(".*");
  std::string regexp2 = std::string(".*") + name + std::string(".*");
  std::string className = std::string("TMVA::Method") + name;
  std::string pluginName = std::string("TMVA") + name;
  std::string ctor1 = std::string("Method") + name + std::string("(DataSetInfo&,TString)");
  std::string ctor2 = std::string("Method") + name + std::string("(TString&, TString&,DataSetInfo&,TString&)");

  gPluginMgr->AddHandler(base.c_str(), regexp1.c_str(), className.c_str(), pluginName.c_str(), ctor1.c_str());
  gPluginMgr->AddHandler(base.c_str(), regexp2.c_str(), className.c_str(), pluginName.c_str(), ctor2.c_str());
}

/**
 * small helper class to keep the TMVAReader and pointers to it contained
 * currently allows only one booked method (but should be no problem for us)
 */
class TMVAReader {
public:
  TMVAReader(std::string method, std::string weightfile); /**< ctor from method name and weightfile*/
  ~TMVAReader() { delete m_reader; } /**< destructor */
  template<class T> void addVariable(std::string name, T& var); /**< add variable */
  std::string getBookMethod() { return m_method; } /**< get the method */
private:
  TMVA::Reader* m_reader;
  std::string m_method;
  std::string m_weightfile;
};

TMVAReader::TMVAReader(std::string method, std::string weightfile)
  : m_method(method), m_weightfile(weightfile)
{
  m_reader = new TMVA::Reader();
  // m_reader->BookMVA(m_method, m_weightfile);
}

template<class T>
void TMVAReader::addVariable(std::string name, T& var)
{
  m_reader->AddVariable(name, &var);
}

///////////////////////////////
// END OF CLASS DECLARATIONS //
///////////////////////////////
/**
 * add the variables to the TMVAReader and book the TMVAMethod
 */
void addVariablesAndBookMethod(TMVAReader& reader,const RootTreeData& tree)
{
  // for(size_t i = 0; i < 9; ++i) { // CAUTION: hardcoded at the moment
  //   std::stringstream name{}; name << "Z" << i;
  //   const std::vector<double> var = tree.getBranchData<double>(name.str())->getData();
  //   reader.addVariable(name.str(), var);
  // }
  // TODO: addVariable takes only a Float_t* -> make a type that holds 9 pointers to doubles and fill them for every sample to feed them to the Tree
  // Variables have to be added before the BookMVA method is called
  // Idea: make type member of TMVAReader and set it in the constructor of TMVAReader
}

/**
 *
 */
void writeToOutput(ofstream& ostream)
{
  // TODO:
}

/**
 * evaluate the TMVA method and write the values to the outputfile
 * TODO:
 */
void evaluate_input(char* weightfile, char* inputfile, char* outputfile)
{
  loadPlugins("FastBDT");

  RootFileData infile = RootFileData(std::string(inputfile));
    infile.fetchData(); // get all data from treeg
  const RootTreeData& tree = infile.getTreeData("testtree");
  TMVAReader reader("FastBDT", std::string(weightfile));
  cout << "created reader" << endl;
  addVariablesAndBookMethod(reader, tree);

  // set the branch addresses for the input file
  // std::array<std::vector<double>,9> inputs;
  // for(size_t i = 0; i < inputs.size(); ++i) {
  //   stringstream name{}; name << "Z" << i; // CAUTION: hardcoded
  //   infile.setBranchAddress(name.str().c_str(), inputs[i]);
  // }


  ofstream outfile(outputfile, ofstream::out);
}


#ifndef __CINT__
/**
 * main routine:
 * TODO
 */
int main(int argc, char* argv[])
{
  if(argc != 4) {
    cout << "please provide: a weightfile, an inputfile and an outputfile (name)" << endl;
    return -1;
  }

  evaluate_input(argv[1],argv[2],argv[3]);

  return 0;
}
#endif
