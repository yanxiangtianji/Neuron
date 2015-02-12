#pragma once
#include "def.h"
#include <string>
#include <istream>
#include <vector>

class SpikeTrains
{
public:
	typedef std::vector<tp_t> SpikeTrain;
public:
	SpikeTrains(const std::string& filename);
	SpikeTrains(std::istream& is);

	bool check_before(const size_t& poss_pnt, const size_t& poss_chd, const tp_t start, const tp_t end, const tp_t delay_th);


	size_t size()const { return n; }

	std::vector<SpikeTrain>& get(){ return cont; }
	const std::vector<SpikeTrain>& get()const{ return cont; }
private:
	size_t n;
	std::vector<SpikeTrain> cont;
};


