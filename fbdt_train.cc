#include "FBDT.h"
#include "FBDT_Writer.h"
#include "tt_timer.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

// timing
#include <chrono>

using namespace FastBDT;
using std::chrono::high_resolution_clock;
using std::chrono::duration_cast;
using namespace timing;

int main(int argc, char* argv[])
{
  if(argc <= 1) {
    std::cerr << "Need a data file" << std::endl;
    return 1;
  }
  std::string outputfilename{"fbdt_weights.xml"};
  if(argc == 3) {
    outputfilename = std::string(argv[2]);
  }

  TicTocTimer timer(1000000); // measure time in ms
  
  std::fstream datastr(argv[1], std::fstream::in);
  std::string line;
  std::vector<std::vector<double> > data;
  std::cout << "reading training data ... " << std::flush;
  timer.tic();
  while(std::getline(datastr, line)) {
    std::stringstream ins{line};
    double val = 0;
    std::vector<double> row;
    while(ins >> val) {
      row.push_back(val);
    }
    data.push_back(row);
  }
  timer.toc();
  std::cout << "DONE. " << timer << std::endl;

  std::cout << "creating FeatureBinnings ... " << std::flush;
  timer.tic();
  std::vector<FeatureBinning<double> > featBins;
  for(size_t iF = 0; iF < 9; ++iF) { // CAUTION: hardcoded to take only the first 9 arguments as inputs
    std::vector<double> feature;
    for(auto& event: data) {
      feature.push_back( event[iF] );
    }
    featBins.push_back(FeatureBinning<double>(8, feature.begin(), feature.end() ));
  }
  timer.toc();
  std::cout << "DONE. " << timer << std::endl;

  std::cout << "creating EventSamples ... " << std::flush;
  timer.tic();
  EventSample eventSamp(data.size(), data[0].size() -1, 8); // 8 bins in FeatureBinning so nLevel = 8 ?
  for(auto& event: data) {
    bool signal = int(event.back()) == 1;
    std::vector<unsigned> bins(9);
    for(size_t iF = 0; iF < 9; ++iF) {
      bins[iF] = featBins[iF].ValueToBin( event[iF] );
    }

    eventSamp.AddEvent(bins, 1.0, signal);
  }
  timer.toc();
  std::cout << "DONE. " << timer << std::endl;

  std::cout << "training FastBDT ...  " << std::flush;
  timer.tic();
  ForestBuilder fbdt(eventSamp, 100, 0.1, 0.5, 3);
  timer.toc();
  std::cout << "DONE. " << timer << std::endl;

  std::cout << "writing XML file ... " << std::flush;
  timer.tic();
  std::fstream treexml(outputfilename.c_str(), std::fstream::out);
  FBDT_Writer writer(treexml);
  writer.writeToFile(fbdt, featBins);
  treexml.close();
  timer.toc();
  std::cout << "DONE. " << timer << std::endl;

  return 0;
}
