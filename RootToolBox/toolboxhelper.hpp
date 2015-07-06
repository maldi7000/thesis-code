
#pragma once

#include <iostream>
#include <algorithm>
#include <string>
#include <tuple>

#include <TObjArray.h>
#include <TList.h>
#include <TIterator.h>
#include <TKey.h>
#include <TObject.h>
#include <TFile.h>
#include <TTree.h>
#include <TClass.h>

#include "RootBranchData.hpp"


namespace RootToolBox {
  
   /**
   * enum to classify the datatype that is stored in a branch as vector<type>
   */
  enum e_dataTypes{
    c_double = 1, /**< branch holds vector<double> */
    c_int = 2, /**<branch holds vector<int> */
    c_uint = 3, /**< branch holds vector<unsigned int> */
    c_usint = 4, /**< branch holds vector <unsigned short int> */
    c_unknown = -1, /**< branch holds other type */
  };
  
  /** get the names from all trees in the TFile 
   * NOTE: source: https://root.cern.ch/phpBB3/viewtopic.php?f=3&t=10421
    * CAUTION: If TTree::AutoSave "kicks in" there are duplicate trees, which will all get found in this way! 
    * Although ROOT manages to get the "right" TTree via TFile::Get("treename"), this function returns the same name multiple times.
    * This results in the same TTree being added to the RootFile multiple times. As long as there is no reading in of data happening there is no problem with this, however if data reading in is involved the data gets read in multiple times.
    * To avoid that: unique is used to filter out duplicate Tree names!
   */
  std::vector<std::string> getTreeNames(TFile* file) 
  {
    std::vector<std::string> names;
    
    TIter nextkey( file->GetListOfKeys() );
    TKey * key, * oldkey = 0;
    while ( (key = (TKey*) nextkey())) {
      TObject* obj = key->ReadObj();
      if(obj->IsA()->InheritsFrom( TTree::Class()) ) {
	TTree* tree = (TTree*) obj;
	names.push_back(std::string(tree->GetName()));
      }
    }
    
    // only return unique names
    std::sort(names.begin(), names.end());
    std::vector<std::string>::iterator newEnd = std::unique(names.begin(), names.end());
    names.resize(std::distance(names.begin(), newEnd));
    
    return names;
  }
  
  /** get the names from all branches in the TTree */
  std::vector<std::string> getBranchNames(TTree* tree)
  {
    std::vector<std::string> names;
    TObjArray* branches = tree->GetListOfBranches();
    for(int i = 0; i < branches->GetEntries(); ++i) 
    {
      TBranch* branch = (TBranch*) branches->At(i);
      names.push_back(std::string(branch->GetName()));
    }
    return names;
  }
  
  /** find the position of a RootObject (RootFile, RootTree, ...) inside a vector of RootObjects with name @param name
   * @returns the index in the vector of the object if it can be found, -1 else
   */
  template<typename RootObject>
  const int getPositionByName(std::vector<RootObject> rootObjects, std::string name)
  {
    int pos = std::find_if(rootObjects.begin(), rootObjects.end(), [&name](const RootObject& object) { return object.getName() == name; } ) - rootObjects.begin();
    if(pos < rootObjects.size()) return pos;
    else return -1;
  }
  
  const int getPositionByName(std::vector<std::tuple<boost::any, std::string, e_dataTypes> > branchdata, std::string name)
  {
    int pos = std::find_if(branchdata.begin(), branchdata.end(), 
			   [&name](const std::tuple<boost::any, std::string, e_dataTypes>& tup) { return std::get<1>(tup) == name; } ) - branchdata.begin();
    if(pos < branchdata.size()) return pos;
    else return -1;
  }
  
  
  /** find the position of @param t in @param vec.
   * @returns the index where t can be found (if t is contained), -1 if t is not contained in vec 
   */
  template<typename T>
  const int getPositionInVector(std::vector<T> vec, T t)
  {
    int pos = std::find(vec.begin(), vec.end(), t) - vec.begin();
    if(pos < vec.size()) return pos;
    else return -1;
  }
  
  e_dataTypes getBranchDataType(TTree* tree, std::string branchname) {
    std::vector<double>* tmpd = 0;
    if(tree->SetBranchAddress(branchname.c_str(), &tmpd) == 0) return c_double;
    
    std::vector<int>* tmpi = 0;
    if(tree->SetBranchAddress(branchname.c_str(), &tmpi) == 0) return c_int;
    
    std::vector<unsigned short int>* tmpusi = 0;
    if(tree->SetBranchAddress(branchname.c_str(), &tmpusi) == 0) return c_usint;
    
    std::vector<unsigned int>* tmpui = 0;
    if(tree->SetBranchAddress(branchname.c_str(), &tmpui) == 0) return c_uint;
    
    return c_unknown;
  }
  
  /**
   * wrapper function that adds a RootBranch with the corresponding data type to treedata
   */
  void addBranchDataToTree(std::vector<std::tuple<boost::any, std::string, e_dataTypes> >& branchdata, TTree* tree, std::string name)
  {
    e_dataTypes dataT = getBranchDataType(tree, name);
    
    switch(dataT) {
      case c_double:
	branchdata.push_back(std::make_tuple(new RootToolBox::RootBranchData<double>(name, tree), name, dataT));
	break;
      case c_int:
	branchdata.push_back(std::make_tuple(new RootToolBox::RootBranchData<int>(name, tree), name, dataT));
	break;
      case c_uint:
	branchdata.push_back(std::make_tuple(new RootToolBox::RootBranchData<unsigned int>(name, tree), name, dataT));
	break;
      case c_usint:
	branchdata.push_back(std::make_tuple(new RootToolBox::RootBranchData<unsigned short int>(name, tree), name, dataT));
	break;
      default:
	std::cout << "WARNING could not deduce a suitable type for branch: " << name << ". This data from this branch will not be fetched!" << std::endl;
    }
	
  
  }
}