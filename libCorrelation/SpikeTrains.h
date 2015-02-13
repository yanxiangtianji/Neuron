#pragma once
#include "def.h"
#include <string>
#include <istream>
#include <vector>

class SpikeTrains
{
public:
	typedef std::vector<tp_t> SpikeTrain;
	typedef std::vector<SpikeTrain> cont_t;
public:
	SpikeTrains(const std::string& filename);
	SpikeTrains(std::istream& is);

	/*!
	@brief Find how many spikes of poss_pnt in range [st_t, end_t] have a corresponding spike within time delay_th on spike train poss_chd.
	@param poss_pnt Index of possible parent spike train (spikes earlier).
	@param poss_chd Index of possible child spike train (spikes latter).
	@param delay_th The delay threshold of considering.
	@param st The start time in poss_pnt.
	@param end The last time in poss_pnt (the last corresponding spike in poss_chd may be latter then it).
	@return pair(the num of countted spikes in poss_pnt, the num of qualified spikes in poss_chd).
	*/
	std::pair<size_t, size_t> check_cospike(const size_t& poss_pnt, const size_t& poss_chd,
		const tp_t delay_th, const tp_t start, const tp_t end);


	size_t size()const { return n; }

	std::vector<SpikeTrain>& get(){ return cont; }
	const std::vector<SpikeTrain>& get()const{ return cont; }
	cont_t::iterator begin(){ return cont.begin(); }
	cont_t::iterator end(){ return cont.end(); }
	cont_t::const_iterator begin()const { return cont.cbegin(); }
	cont_t::const_iterator end()const{ return cont.cend(); }
private:
	size_t n;
	cont_t cont;
};


