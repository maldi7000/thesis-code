#include "FBDT.h"
#include "FBDT_Reader.h"
#include "tt_timer.h"

#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

using namespace FastBDT;
using namespace timing;

/** takes as inputs a .xml file where the FastBDT is stored and a file where the data is stored*/
int main(int argc, char* argv[])
{
  if(argc < 3) {
    std::cerr << "need a .xml file, a data file! (in this order)" << std::endl;
    return 1;
  }

  TicTocTimer timer(1000000); // want ms
  // read in .xml file and construct FastBDT::Forest from it
  std::fstream weights(argv[1], std::fstream::in);
  std::cout << "reading in weight file ... " << std::flush;
  timer.tic();
  FBDT_Reader reader(weights);
  Forest fbdt = reader.getFastBDT();
  std::vector<FeatureBinning<double> > featBins = reader.getFeatureBinnings();
  weights.close();
  timer.toc();
  std::cout << "DONE. " << timer << std::endl;

  size_t nInputs = featBins.size();
  // read in data and pass it to the fbdt to be analyzed
  std::fstream datafs(argv[2], std::fstream::in);
  std::string line;
  std::cout << "reading in data ... " << std::flush;
  timer.tic();
  std::vector<std::vector<unsigned> > data;
  while(std::getline(datafs, line)) {
    if(line.empty()) break;
    std::stringstream sin{line};
    std::vector<unsigned> bins(nInputs);
    for(size_t i = 0; i < nInputs; ++i) {
      double val;
      sin >> val;
      bins[i] = featBins[i].ValueToBin(val);
    }
    data.push_back(bins);
  }
  timer.toc();
  std::cout << "DONE. " << timer << std::endl;

  std::vector<double> outputs;
  outputs.reserve(data.size());
  std::cout << "evaluating data ... " << std::flush;
  timer.tic();
  for(const auto& bins: data) {
    outputs.push_back(fbdt.Analyse(bins));
  }
  timer.toc();
  std::cout << "DONE. " << timer << std::endl;

  std::fstream outfs(argv[3], std::fstream::out);
  std::cout << "writing output data ... " << std::flush;
  timer.tic();
  for (const double& val : outputs) { outfs << val << std::endl; }
  timer.toc();
  std::cout << "DONE. " << timer << std::endl;

  return 0;
}
