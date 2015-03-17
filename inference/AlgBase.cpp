#include "AlgBase.h"

using namespace std;


void AlgBase::set_mpps_by_ppm(ppm_t& ppm){
	size_t n = size();
	mpps.clear();
	mpps.resize(n);
	for(size_t i = 0; i < n; ++i){
		for(size_t j = 0; j < n; ++j){
			if(ppm[i][j])
				mpps[j].push_back(i);
		}
	}
}

bool AlgBase::contains(const ps_t& lth, const ps_t& rth){
	if(lth.size() < rth.size() || rth.size() == 0)
		return false;
	for(size_t p : rth){
		if(find(lth.begin(), lth.end(), p) == lth.end())
			return false;
	}
	return true;
}
bool AlgBase::equals(const ps_t& lth, const ps_t& rth){
	return lth == rth;
}
bool AlgBase::share_n_loop(const size_t i, const ps_t& lth, const size_t j, const ps_t& rth){
	if(lth.size() != rth.size())
		return false;
	ps_t temp_l(lth);
	auto itl = find(temp_l.begin(), temp_l.end(), j);
	if(itl == temp_l.end())
		return false;
	if(find(rth.begin(), rth.end(), i) == rth.end())
		return false;
	*itl = i;
	return temp_l == rth;
}

void AlgBase::output_vps(std::ostream& os, const std::vector<ps_t>& vps){
	size_t n = vps.size();
	os << n << '\n';
	for(size_t i = 0; i < n; ++i){
		os << i << ' ' << vps[i].size() << '\n';
		for(size_t pid : vps[i])
			os << ' ' << pid;
		os << '\n';
	}
}

