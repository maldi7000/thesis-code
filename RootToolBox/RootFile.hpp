// tmadlener: my try on making some kind of a toolbox that can be easily reused to handle root stuff
// RootFile: wraps the root file-handling (sort of)

#pragma once

#include <iostream>
#include <vector>
#include <string>
#include <algorithm> // find

#include "RootTree.hpp"
#include "toolboxhelper.hpp"

// ROOT stuff
#include <TFile.h>
#include <TTree.h>

namespace RootToolBox {
  
  /** class handling all the root file stuff (i.e. trees etc) */
  class RootFile {
    
  public:
        
    /** ctor with file- and treenames, if you know treenames and only want to use certain of them use this ctor */
    RootFile(std::string filename, std::vector<std::string> treenames) : __filename(filename)
    {
      setFile(filename);
      fetchTrees(treenames);
    }
    
    /** ctor with filename, gets all trees and subsequently all branches for this file */
    RootFile(std::string filename); 
    
    /** dtor */
//     ~RootFile(); // TODO
    
    /** set the filename and try to open the file */
    void setFile(std::string filename);
    
    /** get pointer to file */
    TFile* getFilePtr() const { return __file; }
    
    std::string getName() const { return __filename; }
    
    /** get the number of trees (to which the pointer exists in the container) */
    size_t getNTrees() const { return __trees.size(); }
    
    /** get all trees that are currently attached to this RootFile */
    std::vector<RootToolBox::RootTree> getTrees() const { return __trees; }
    
    /** try to find a tree with the passed name */
    RootToolBox::RootTree getTree(std::string name) const;
    
    /** get the tree with the passed index */
    RootToolBox::RootTree getTree(int index) const;
    
    void print() const;
    
  protected:
    TFile* __file; /**< pointer to the file */
    std::string __filename; /**< the fileName */
    std::vector<RootToolBox::RootTree> __trees; /**< informtion on the trees of the file */
    
    void fetchTrees(std::vector<std::string> treenames);
  };
  
  
  // ================================================ CTOR FROM FILENAME ==========================================================
  RootFile::RootFile ( std::string filename ) : __filename(filename)
  {
    setFile(filename);
    std::vector<std::string> treenames = getTreeNames(__file);
    fetchTrees(treenames);
  }
  // ==============================================================================================================================
  
  // ================================================== DTOR ======================================================================
//   RootFile::~RootFile()
//   {
//     __trees.clear();
//     __filename.clear();
//     delete __file;
//   }

  // ==============================================================================================================================
  
  // ============================================= SET FILE =======================================================================
  void RootFile::setFile (std::string filename)
  {
    __filename = filename;
    __file = TFile::Open(filename.c_str());
    if(__file != 0) std::cout << "opened root file: " << filename << std::endl;
    else {
      std::cout << "could not open root file!" << std::endl;
      exit(-1);
    }
  }
  // ==============================================================================================================================
  
  // ====================================================== FETCH TREES ===========================================================
  void RootFile::fetchTrees (std::vector<std::string> treenames)
  {
    for(std::string name : treenames) { __trees.push_back(RootTree(name, __file)); }
  }
  // ==============================================================================================================================
  
  // ================================================= GET TREE ===================================================================
  RootTree RootFile::getTree ( std::string name ) const
  {
    int pos = RootToolBox::getPositionByName(__trees, name);
    if(pos != -1) return getTree(pos);
    else std::cout << "found no tree with name " << name << "! Returning empty RootTree" << std::endl;
    
    return RootTree();
  }

  RootTree RootFile::getTree ( int index ) const
  {
    if(index >= 0 && index < __trees.size()) return __trees[index];
    else std::cout << "index is out of range! returning empty RootTree!" << std::endl;
    
    return RootTree();
  }
  // ==============================================================================================================================
  
  // ========================================= PRINT ==============================================================================
  void RootFile::print() const
  {
    std::cout << "contents of file " << __filename << ": " << __trees.size() << " trees" << std::endl;
    for (const RootTree& tree : __trees) { tree.print(); }
  }
  // ==============================================================================================================================
  
}