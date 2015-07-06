#pragma once

#include "RootFile.hpp"
#include "RootTreeData.hpp"
#include "toolboxhelper.hpp"

// boost
// #include <boost/any.hpp>

namespace RootToolBox {
  
  class RootFileData : public RootFile {
  public:
    
    /** ctor from name */
    RootFileData(std::string filename);
    
    RootFileData(std::string filename, std::vector<std::string> treenames);
    
    /** get the vector of RootTreeData */ // TODO: check if return of const reference is good idea!
    const std::vector<RootTreeData>& getTreesData() const { return __treesdata; }
    
    /** get the data from only one tree */ // TODO: check if return of const reference is good idea!
    const RootTreeData& getTreeData(std::string treename) const;
    
    /** get the data from only one tree by index */
    const RootTreeData& getTreeData(int index) const;
    
    /** only get data from a certain event (iEvent) */
    void fetchData(int iEvent, RootToolBox::RootTreeData& treedata);
    
    /** fetch all data from events between iEvent1, and iEvent2 (inclucding iEvent1, excluding iEvent2) */
    void fetchData(int iEvent1, int iEvent2);
    
    /** fetch the data from all events */
    void fetchData();
    
  protected:
    std::vector<RootTreeData> __treesdata;
  };
  
  RootFileData::RootFileData ( std::string filename ) : RootFile ( filename )
  {
    std::vector<std::string> treenames = getTreeNames(__file);
    for (std::string name : treenames) __treesdata.push_back(RootTreeData(name, __file));
  }

  RootFileData::RootFileData ( std::string filename, std::vector< std::string > treenames ) : RootFile ( filename, treenames )
  {
    for (std::string name : treenames) __treesdata.push_back(RootTreeData(name, __file));
  }

  
  
  // ========================================================= GET TREE DATA ======================================================
  const RootTreeData& RootFileData::getTreeData ( std::string treename ) const
  {
    int pos = getPositionByName(__treesdata, treename);
    if(pos != -1) return getTreeData(pos);
    else std::cout << "found no tree with name " << treename << "! Returning first treedata!" << std::endl;
    
    return getTreeData(0); // TODO: make that there is an empty return if this happens!
  }

  const RootTreeData& RootFileData::getTreeData ( int index ) const
  {
    if(index >= 0 && index < __treesdata.size()) return __treesdata[index];
    else std::cout << "index is out of range! returning first RootTreeData!" << std::endl;
    
    return __treesdata[0];
  }

  
  // ============================================================ FETCH DATA ======================================================
  void RootFileData::fetchData ( int iEvent, RootTreeData& treedata )
  {
      treedata.addEvent(iEvent);
  }

  void RootFileData::fetchData ( int iEvent1, int iEvent2 )
  {
    for(RootTreeData& tree: __treesdata) {
      std::cout << "fetching data from event " << iEvent1 << " to event " << iEvent2 << " from tree " << tree.getName() << std::endl;
      for(int i = iEvent1; i < iEvent2; ++i) fetchData(i,tree);
    }
  }

  // ========================================= FETCH DATA =========================================================================
  void RootFileData::fetchData()
  {
    for(RootTreeData& tree : __treesdata) {
      int nEntries = tree.getTreePtr()->GetEntries();
      std::cout << "fetching " << nEntries << " events from tree " << tree.getName() << std::endl;
      for (int i = 0; i < nEntries; ++i) fetchData(i, tree);
    }
  }

}