// tmadlener: my try on making some kind of a toolbox that can be easily reused to handle root stuff
#pragma once

#include <vector>
#include <string>

// ROOT
#include <TFile.h>
#include <TTree.h>
#include <TObjArray.h>

// root toolbox 
// #include "RootFile.h"
#include "RootBranch.hpp"
#include "toolboxhelper.hpp"
// boost
// #include <boost/any.hpp>


namespace RootToolBox {
  
  /** class holding information on a given tree */
  class RootTree {
  public:
    
    /** empty ctor, needed for returning empty trees */
    RootTree() : __tree(NULL), __treename("") {}
    
    /** ctor from treename and the file where the tree is */
    RootTree(std::string treename, TFile* file);
    
    /** dtor */
//     ~RootTree(); // TODO
    
    std::string getName() const { return __treename; } /**< get the name of the tree */
    
    TTree* getTreePtr() const { return __tree; } /**< get the pointer to the tree */
    
    size_t getNBranches() const { return __branches.size(); } /**< get the number of branches currently attached to tree */
    
    RootToolBox::RootBranch getBranch(std::string name) const; /**< get the branch with the passed name */
    
    RootToolBox::RootBranch getBranch(int index) const; /**< get the branch with the passed index (i.e. index is position in vector) */
    
    std::vector<RootToolBox::RootBranch> getBranches() const { return __branches; } /**< get all branches currently attached */
    
    void print() const; /**< print tree */
  protected:
    std::string __treename; /**< name of tree */
    TTree* __tree; /**< pointer to tree */
    std::vector<RootToolBox::RootBranch> __branches; /**< branch information for this tree */
    
    /** get the passed branches (by name) and add them to the branch vector */
    void fetchBranches(std::vector<std::string> branchnames);
  };
  
  // ======================================= CTOR ===============================================================================
  RootTree::RootTree(std::string treename, TFile* file) : __treename(treename)
  {
    __tree = (TTree*) file->Get(treename.c_str());
    std::vector<std::string> branchnames = getBranchNames(__tree);
    fetchBranches(branchnames);
  }
  // ============================================================================================================================
  
  // ======================================= DTOR ===============================================================================
//   RootTree::~RootTree()
//   {
//     __branches.clear();
//     __treename.clear();
//     delete __tree;
//   }
  // ============================================================================================================================
  
  // =============================================== FETCH BRANCHES =============================================================
  void RootTree::fetchBranches(std::vector<std::string> branchnames)
  {
    for(std::string name : branchnames) __branches.push_back(RootBranch(name, __tree));
  }
  // ============================================================================================================================
  
  // ================================================= GET BRANCH ===============================================================
  RootBranch RootTree::getBranch ( int index ) const
  {
    if(index >= 0 && index < __branches.size()) return __branches[index];
    else std::cout << " index is out of range. returning empty RootBranch! " << std::endl;
    
    return RootBranch();
  }
  
  RootBranch RootTree::getBranch ( std::string name ) const
  {
    int pos = RootToolBox::getPositionByName(__branches, name);
    if(pos != -1) return getBranch(pos);
    else std::cout << "found no Branch with name " << name << " returning empty RootBranch" << std::endl;
    
    return RootBranch();
  }
  
  // ========================================================= PRINT ==============================================================
  void RootTree::print() const
  {
    std::cout << "content of tree " << __treename << ": " << __branches.size() << " branches" << std::endl;
    for(const RootBranch& branch : __branches) { branch.print(); }
  }

}