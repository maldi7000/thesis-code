// tmadlener: my try on making some kind of a toolbox that can be easily reused to handle root stuff

#pragma once

#include <vector>
#include <string>
#include <iostream>
#include <sstream>

// ROOT
#include <TBranch.h>
#include <TTree.h>

// boost
#include <boost/any.hpp>

namespace RootToolBox {

  /** class that handles branch stuff from root, T is the type of the values in the Branch */
  class RootBranch {
  public:

    /** empty ctor */
    RootBranch() : __name(""), __branch(NULL) {}

    /** ctor from string and TTree */
    RootBranch(std::string name, TTree* tree);

    /** dtor */
//     ~RootBranch(); // TODO

    /** get the name of the branch */
    std::string getName() const { return __name; }

    /** get the pointer to the branch */
    TBranch* getBranchPtr() const { return __branch; }

    /** print branch */
    void print() const;

  protected:
    std::string __name; /**< name of the branch inside the TTree */
    TBranch* __branch; /**< the pointer to the acutal TBranch */
  };

  // =================================== CTOR FROM STRING AND TREE ==============================================================
  RootBranch::RootBranch(std::string name, TTree* tree) : __name(name)
  {
    __branch = tree->GetBranch(name.c_str());
  }
  // ============================================================================================================================

  // ==================================================== DTOR ==================================================================
//   RootBranch::~RootBranch()
//   {
//     __name.clear();
//     delete __branch;
//   }
  // ============================================================================================================================

  void RootBranch::print() const
  {
    std::cout << "content of branch " << __name << ":" << std::endl;
  }

}
