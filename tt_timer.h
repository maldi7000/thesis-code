#include <chrono>
#include <string>
#include <sstream>
#include <ostream>

namespace timing { 
  /**
   * Timer class that somewhat mimics the tic-toc behavior of MATLAB.
   * Use tic() to start a time measurement and toc() to end it.
   * The base unit of the measurement is nanoseconds (ns) but the desired unit can be chosen by the user
   */
  class TicTocTimer {
  public:
    /**
     * constructor (also works as tic)
     * @param convFactor, factor by which the base unit is divided for the output (i.e. for us convFactor = 1000)
     * @param name, name of the timer
     */
    TicTocTimer(unsigned convFactor = 1, std::string name = "");

    void tic(); /**< reset the starting time */

    void toc(); /**< stop the time measurement */

    std::string print() const; /**< print the name of the timer and the elapsed time */

    /** get the time measured by the timer (if possible), if only tic has been called a negative time is returned */
    double time() const;
    
    std::string getName() const { return m_name; } /**< get the name of the timer */

    std::string getUnit() const { return m_unit; } /**< get the unit of the timer */

  private:
    unsigned int m_convFactor; /**< conversion factor to be used to convert from nanoseconds to any other unit by division */

    std::string m_name; /**< name of the instance */

    bool m_tocked; /**< bool to indicate if both toc has been called after a call to tic */

    std::string m_unit; /**< the unit used for the time measurement */

    std::chrono::high_resolution_clock::time_point m_start; /**< starting time point of the current time measurement */

    std::chrono::high_resolution_clock::time_point m_end; /**< end time point of the current time measurement */
  };

  TicTocTimer::TicTocTimer(unsigned convFactor, std::string name) :
    m_convFactor(convFactor),
    m_name(name),
    m_tocked(false),
    m_unit("ns")
  {
    switch(m_convFactor) {
    case 1: break;
    case 1000:
      m_unit = "us"; break;
    case 1000000:
      m_unit = "ms"; break;
    case 1000000000:
      m_unit = "s"; break;
    default:
      std::stringstream ss{};
      ss << " / " << m_convFactor << " ns";
      m_unit = ss.str();
    }
    tic();
  }

  void TicTocTimer::tic()
  {
    m_tocked = false;
    m_start = std::chrono::high_resolution_clock::now();
  }

  void TicTocTimer::toc()
  {
    m_tocked = true;
    m_end = std::chrono::high_resolution_clock::now();
  }

  double TicTocTimer::time() const
  {
    if(!m_tocked) return -1;
    return std::chrono::duration_cast<std::chrono::nanoseconds>(m_end - m_start).count() / m_convFactor;
  }

  std::string TicTocTimer::print() const
  {
    std::stringstream ss{};
    ss << m_name << " elapsed time: " << time() << " " << getUnit();
    return ss.str();
  }
  
  std::ostream& operator<<(std::ostream& os, const TicTocTimer& timer) {
    os << timer.print();
    return os;
  }
}
