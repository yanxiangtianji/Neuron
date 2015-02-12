#include "SpikeTrains.h"
#include <fstream>
#include <stdexcept>

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

