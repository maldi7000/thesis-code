#pragma once

#include "RootTree.hpp"
#include "RootBranchData.hpp"
#include "toolboxhelper.hpp"
// #include "RootCut.hpp"

#include <tuple>
#include <iostream>

#include <boost/any.hpp>

namespace RootToolBox {

 /** class holding the data that is contained in a tree */
  class RootTreeData : public RootTree {
  public:

  /** constructor from a RootFile and a treename */
    RootTreeData(std::string treename, TFile* file);

    template<typename T>
    RootBranchData<T>* getBranchData( std::string name ) const;

    template<typename T>
    RootBranchData<T>* getBranchData( int index ) const;

//     void applyCut(std::vector<RootToolBox::RootCut> cuts); // TODO when there is more time!

    void addEvent(int iEvent);

  protected:
    std::vector<std::tuple<boost::any, std::string, e_dataTypes> > __branchdata;
  };


  RootTreeData::RootTreeData ( std::string treename, TFile* file ) : RootTree ( treename, file )
  {
    std::vector<std::string> branchnames = getBranchNames(__tree);
    for(std::string name : branchnames) { addBranchDataToTree(__branchdata, __tree, name); }
  }

  template<typename T>
  RootBranchData<T>* RootTreeData::getBranchData ( std::string name ) const
  {
    int pos = getPositionByName(__branchdata, name);
//     std::cout << "trying to get branch " << name << std::endl;
    if(pos != -1) return getBranchData<T>(pos);
    else std::cout << "found no Branch with name " << name << " returning empty RootBranchData" << std::endl;

    exit(-2);
  }

  template<typename T>
  RootBranchData<T>* RootTreeData::getBranchData ( int index ) const
  {
//     std::cout << "trying to get branch by index " << index << std::endl;
    if (index >= 0 && index < __branchdata.size()) return boost::any_cast<RootToolBox::RootBranchData<T>*>(std::get<0>(__branchdata[index]));
//     if(index >= 0 && index < __bdata.size()) return boost::any_cast<RootBranchData<T> >(__bdata[index]);
    else std::cout << "index is out of range!" << std::endl;

    exit(-2);
  }

  // ==================================================== ADD EVENT ===============================================================
  void RootTreeData::addEvent ( int iEvent )
  {
    for(size_t iBr = 0; iBr < __branchdata.size(); ++iBr) {
      e_dataTypes datatype = std::get<2>(__branchdata[iBr]);
      switch(datatype) {
	case c_double: {
	  boost::any_cast<RootToolBox::RootBranchData<double>* >(std::get<0>(__branchdata[iBr]))->addEvent(iEvent);
	  break;
	}
	case c_int: {
	  boost::any_cast<RootBranchData<int>* >(std::get<0>(__branchdata[iBr]))->addEvent(iEvent);
	  break;
	}
	case c_uint: {
	  boost::any_cast<RootBranchData<unsigned int>* >(std::get<0>(__branchdata[iBr]))->addEvent(iEvent);
	  break;
	}
	case c_usint: {
 	  boost::any_cast<RootBranchData<unsigned short int>* >(std::get<0>(__branchdata[iBr]))->addEvent(iEvent);
	  break;
	}
	default: {
	  std::cout << "could not get type. Exiting!" << std::endl;
	  exit(-2);
	}
      }
    }
  }

}
