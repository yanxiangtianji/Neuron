#include "FirstAlg.h"

using namespace std;

FirstAlg::FirstAlg(const tp_t window_size, const tp_t start, const tp_t end, const std::string& fn)
	:AlgBase(), dh(window_size, start, end, fn)
{
}

void FirstAlg::set_mpps(const double cor_th){
	const tp_t delay_th = _mpps_param_delay_th;
	const double cospike_dif_tol = _mpps_param_cospike_dif_tol;
	ppm_t ppm = cal_by_cor(cor_th);
	refine_ppm_by_delay(ppm, delay_th, cospike_dif_tol);
	set_mpps_by_ppm(ppm);
}

FirstAlg::ppm_t FirstAlg::cal_by_cor(const double threshold){
	size_t n = dh.size();
	ppm_t res;
	res.reserve(n);
	for(size_t i = 0; i < n; ++i){
		ppm_t::value_type temp(n,false);
		for(size_t j = 0; j < n; ++j){
			if(i == j)
				temp[j] = false;
			else if(dh.cor_dp_f(i, j) >= threshold)
				temp[j] = true;
		}
		res.push_back(move(temp));
	}
	return res;
}

void FirstAlg::refine_ppm_by_delay(ppm_t& ppm, const tp_t delay_th, const double cospike_dif_tol){
	size_t n = size();
	for(size_t i = 0; i < n; ++i){
		for(size_t j = 0; j < n; ++j){
			if(ppm[i][j]){
				pair<size_t, size_t> p = dh.check_cospike(i, j, delay_th);
				//p.first spikes in i; p.second qualified spikes in j
				ppm[i][j] = p.second >= p.first*cospike_dif_tol;
			}
		}
	}
}

void FirstAlg::set_mpps_by_ppm(ppm_t& ppm){
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


void FirstAlg::set_ps_by_mpps(){
	size_t n = size();
	ps = mpps;
	bool goon = true;
	//TODO: change to SPFA like algorithm
	while(goon){
		goon = false;
		for(size_t i = 0; i < n; ++i){
			for(size_t j = 0; j < n; ++j){
				if(i == j || ps[i].size()==0 || ps[j].size()==0)
					continue;
				//indirect: remove indirect links
				if(contains(ps[i], ps[j]) && !equals(ps[i], ps[j])){
					goon = true;
					for(size_t p : ps[j])
						ps[i].erase(find(ps[i].begin(), ps[i].end(), p));
				}
				//common input: remove spurious link loop among children sharing common parents
				if(share_n_loop(i,ps[i],j, ps[j])){
					ps[i].erase(find(ps[i].begin(), ps[i].end(), j));
					ps[j].erase(find(ps[j].begin(), ps[j].end(), i));
				}
			}
		}
	}
}
