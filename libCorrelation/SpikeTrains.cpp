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

bool SpikeTrains::check_before(
	const size_t& anchor, const size_t& rth, const tp_t start, const tp_t end, const tp_t delay_th)
{
	SpikeTrain& src = cont[anchor];
	SpikeTrain& dst = cont[rth];
	auto itsf = lower_bound(src.begin(), src.end(), start);
	auto itsl = lower_bound(src.begin(), src.end(), end);
	if(itsf == itsl)
		return false;
	while(itsf != itsl){
		auto itd = lower_bound(dst.begin(), dst.end(), *itsf);
		if(itd == dst.begin())
			return false;
		--itd;
		if(*itsf-delay_th<*itd || *itsf<*itd)
			return false;
		++itsf;
	}
	return true;
}
