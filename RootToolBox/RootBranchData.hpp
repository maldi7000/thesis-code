#pragma once

#include "RootBranch.hpp"

namespace RootToolBox {
  
    /** class that holds the data that is in a branch */
  template<typename T> class RootBranchData {
  public:
    
    /** empty ctor */
    RootBranchData() : __branch(NULL), __name("") {}
    
    /** ctor from string and TTree */
    RootBranchData(std::string name, TTree* tree);
    
    /** fetch data from event (iEvent) from the rootfile and add it to the __data vector */
    void addEvent(int iEvent);
    
    /** get (a reference to the vector) data */
    const std::vector<T>& getData() const { return __data; }
    
    /** forward call to __rootBranch */
    std::string getName() const { return __rootBranch.getName(); }
    
    TBranch* getBranchPtr() const { return __rootBranch.getBranchPtr(); }
    
    void print() const { __rootBranch.print(); }
    
  protected:
    std::vector<T> __data; /**< content of the branch */ // NOTE: somehow this has to be expanded to take other types aswell!
    
    RootToolBox::RootBranch __rootBranch;
    
    TBranch* __branch;
    std::string __name;
  };
  
  template<typename T>
  RootBranchData<T>::RootBranchData(std::string name, TTree* tree) : __name(name)
  {
    __branch = tree->GetBranch(name.c_str());
  }
  
  // ================================================= FETCH DATA =================================================================
  template<typename T>
  void RootBranchData<T>::addEvent ( int iEvent )
  {    
    if(iEvent >= __branch->GetEntries() || iEvent < 0) {
      std::cout << "trying to fetch event " << iEvent << " but branch contains only " << __branch->GetEntries() << std::endl;
      return;
    }
    
    std::vector<T>* tmp = 0; // temporary pointer to vector needed for SetAddress
    __branch->SetAddress(&tmp);
    __branch->GetEntry(iEvent);
    
    int getRes = __branch->GetEntry(iEvent); // preserve value to do some error catching
    if(getRes == 0) {
      std::cout << "entry " << iEvent << " does not exist for branch " << __name <<  "!" << std::endl;
      return;
    } else if (getRes < 0) {
      std::cout << "ERROR: there was a I/O conversion issue while getting entry " << iEvent << " from branch " << __name << std::endl;
      return;
    }
    if(tmp != 0) {
      for(T d : *tmp) {
	__data.push_back(d);
// 	std::cout << " added " << d << " to __data" << std::endl;
      }
    }
    
  }
}