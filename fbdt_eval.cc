#include "FBDT.h"
#include "FBDT_Reader.h"

#include <iostream>
#include <iomanip>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

using namespace FastBDT;

/** takes as inputs a .xml file where the FastBDT is stored and a file where the data is stored*/
int main(int argc, char* argv[])
{
  if(argc < 2) {
    std::cerr << "need a .xml file and a data file! (in this order)" << std::endl;
    return 1;
  }

  // read in .xml file and construct FastBDT::Forest from it
  std::fstream weights(argv[1], std::fstream::in);
  FBDT_Reader reader(weights);
  Forest fbdt = reader.getFastBDT();
  std::vector<FeatureBinning<double> > featBins = reader.getFeatureBinnings();
  weights.close();
  
  size_t nInputs = featBins.size();
  size_t nLevels = featBins[0].GetNLevels();
  // read in data and pass it to the fbdt to be analyzed
  std::fstream data(argv[2], std::fstream::in);
  std::string line;
  while(std::getline(data, line)) {
    if(line.empty()) break;
    std::stringstream sin{line};
    std::vector<unsigned> bins(nLevels);
    for(size_t i = 0; i < nInputs; ++i) {
      float val;
      sin >> val;
      bins[i] = featBins[i].ValueToBin(val);
    }
    // std::cout << std::fixed <<  std::setprecision(10) << fbdt.Analyse(bins) << std::endl;
    std::cout << fbdt.Analyse(bins) << std::endl;
  }
  
  return 0;
}
