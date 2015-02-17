#include "SpikeTrains.h"
#include <fstream>
#include <stdexcept>
#include <algorithm>

using namespace std;

SpikeTrains::SpikeTrains(const std::string& filename):SpikeTrains(ifstream(filename))
{
}

SpikeTrains::SpikeTrains(std::istream& is){
	if(!is){
		throw invalid_argument("Error in reading spike trains.");
	}
	n = 0;
	int id;
	size_t n_spike;
	while(is >> id >> n_spike){
		++n;
		vector<tp_t> temp;
		temp.reserve(n_spike);
		while(n_spike--){
			tp_t t;
			is >> t;
			temp.push_back(t);
		}
		cont.push_back(move(temp));
	}
	cont.shrink_to_fit();
}

std::pair<size_t, size_t> SpikeTrains::check_cospike(
	const size_t& poss_pnt, const size_t& poss_chd, const tp_t delay_th, const tp_t start, const tp_t end)
{
	SpikeTrain& src = cont[poss_pnt];
	SpikeTrain& dst = cont[poss_chd];
	auto itsf = lower_bound(src.begin(), src.end(), start);
	auto itsl = lower_bound(src.begin(), src.end(), end);
	if(itsf == itsl)
		return make_pair<size_t,size_t>(0,0);
	size_t len = itsl - itsf;
	auto itdf = lower_bound(dst.begin(), dst.end(), start);
	auto itdl = lower_bound(dst.begin(), dst.end(), end);
	if(itdl != dst.end())
		++itdl;
	size_t res=0;
	while(itsf != itsl){
		//*itd>=*itsf
		auto itd = lower_bound(itdf, itdl, *itsf);
		if(itd != itdl && *itsf + delay_th >= *itd)
			++res;
		++itsf;
	}
	return make_pair(len, res);
}
