// tmadlener: 25.03.2015 -> do this when there is more time

// #pragma once
//
// #include <iostream>
// #include <string>
// #include <vector>
//
// namespace RootToolBox {
//
//   /** class to define a cut to be applied to the data from a tree */
//   class RootCut {
//
//   public:
//
//     RootCut() : __name(""), __lower(false) {} /**< empty ctor to avoid unintended behavior */
//
//     RootCut(std::string name, std::vector<double> values); /**< ctor from name and two values (first is low, second is high) */
//
//     RootCut(std::string name, double value, bool low); /**< ctor from name and one value, as well as a bool to indicate if the value has to be higher (false) or lower (true) to survive the cut */
//
//     bool passCut(double value) const;
//
//   protected:
//     std::string __name; /** the name of the branch that holds the values that shall be used to cut */
//
//     std::vector<double> __cutvalues;
//
//     bool __lower;
//
//   };
//
//   RootCut::RootCut(std::string name, std::vector<double> values) : __name(name)
//   {
//     if(values.size() > 2) { std::cout << "in ctor of RootCut, got " << values.size() << " values, will only use the firs two!" << std::endl; }
//     if(values.size() < 2) {
//       std::cout << "in ctor of RootCut, got " << values.size() << " values. Need two!" << std::endl;
//       exit(-4);
//     }
//     for(size_t i = 0; i < 2; ++i) { __cutvalues.push_back(values[i]); }
//   }
//
//   RootCut::RootCut(std::string name, double value, bool low) : __name(name), __lower(low)
//   {
//     __cutvalues.push_back(value);
//   }
//
//   bool RootCut::passCut(double value) const
//   {
//     if(__cutvalues.size() == 2) {
//       return (value >= __cutvalues[0]) && (value < __cutvalues[1]);
//     } else if (__cutvalues.size() == 1) {
//       return __lower ^ (value > __cutvalues[0]); // using XOR here
//     }
//
//     return false; // default return is false
//   }
//
// }
