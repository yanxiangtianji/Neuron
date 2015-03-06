#include "SecondAlg.h"

using namespace std;

SecondAlg::SecondAlg(const tp_t window_size, const tp_t start, const tp_t end, const std::string& fn)
	:dh(window_size, start, end, fn)
{
	_init();
}

void SecondAlg::_init(){
	vector<SCV> temp(dh.get_cont());
	size_t w = dh.get_window_size();
	size_t s = dh.get_start_t();
	size_t e = dh.get_end_t();
	vector<SCV> res;
	for(auto& scv : temp){
		vector<SCV::value_type> v = scv.get_vec();
		for(size_t i = 1; i < v.size(); ++i)
			v[i - 1] = v[i] - v[i - 1];
		v.erase(--v.end());
		res.push_back(SCV(w, s, e, v));
	}
	res.shrink_to_fit();
	dh = DataHolder(w, s, e, move(res));
}

void SecondAlg::set_ps(const double cor_th){
	ppm_t ppm = cal_by_cor(cor_th);
	set_ps_by_ppm(ppm);
}

SecondAlg::ppm_t SecondAlg::cal_by_cor(const double threshold){
	size_t n = dh.size();
	ppm_t res;
	res.reserve(n);
	for(size_t i = 0; i < n; ++i){
		ppm_t::value_type temp(n, false);
		for(size_t j = 0; j < n; ++j){
			if(i == j)
				temp[j] = false;
			else if(dh.pearson_correlation(i, j) >= threshold)
				temp[j] = true;
		}
		res.push_back(move(temp));
	}
	return res;
}


void SecondAlg::set_ps_by_ppm(ppm_t& ppm){
	size_t n = size();
	ps.clear();
	ps.resize(n);
	for(size_t i = 0; i < n; ++i){
		for(size_t j = 0; j < n; ++j){
			if(ppm[i][j])
				ps[j].push_back(i);
		}
	}
}


void SecondAlg::output_vps(std::ostream& os, const std::vector<ps_t>& vps){
	size_t n = vps.size();
	os << n << '\n';
	for(size_t i = 0; i < n; ++i){
		os << i << ' ' << vps[i].size() << '\n';
		for(size_t pid : vps[i])
			os << ' ' << pid;
		os << '\n';
	}
}
