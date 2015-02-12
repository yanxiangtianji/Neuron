#include "FirstAlg.h"

using namespace std;

FirstAlg::FirstAlg(std::string& fn, const tp_t window_size, const tp_t start, const tp_t end)
	:dh(window_size, start, end, fn)
{
}

void FirstAlg::set_mpps(const double cor_th, const tp_t delay_th){
	ppm_t ppm = cal_by_cor(cor_th);
	refine_ppm_by_delay(ppm, delay_th);
	set_mpps_by_ppm(ppm);
}

FirstAlg::ppm_t FirstAlg::cal_by_cor(const double threshold){
	size_t n = dh.size();
	ppm_t res(n);
	for(size_t i = 0; i < n; ++i){
		ppm_t::value_type temp(n,false);
		for(size_t j = 0; j < n; ++j){
			if(i == j)
				temp[j] = false;
			if(dh.cor_dp_f(i, j) >= threshold)
				temp[j] = true;
		}
	}
	return res;
}

void FirstAlg::refine_ppm_by_delay(ppm_t& ppm, const tp_t delay_th){

}

void FirstAlg::set_mpps_by_ppm(ppm_t& ppm){
	size_t n = size();
	mpps.clear();
	mpps.resize(n);
	for(size_t i = 0; i < n; ++i){
		for(size_t j = 0; j < n; ++j){
			if(ppm[i][j])
				mpps[i].push_back(j);
		}
	}
}

