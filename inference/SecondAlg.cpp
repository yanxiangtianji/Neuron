#include "SecondAlg.h"
//#include <iostream>
#include <iomanip>
#include <fstream>

using namespace std;

SecondAlg::SecondAlg(const tp_t window_size, const tp_t start, const tp_t end, const std::string& fn)
	:AlgBase(), dh(window_size, start, end, fn)
{
	_init_to_delta();
}

void SecondAlg::_init_to_delta(){
	vector<SCV>& temp=dh.get_cont();
	size_t l = temp[0].get_length();
	size_t w = dh.get_window_size();
	for(SCV& scv : temp){
		vector<SCV::value_type> v = scv.get_vec();
		for(size_t i = 1; i < l; ++i)
			v[i - 1] = v[i] - v[i - 1];
		v.erase(--v.end());
		scv.set_start(dh.get_start_t()+w);
//		for(auto&t : v)	cout << setw(3) << t;
//		cout << endl;
		if(!scv.set_vec(move(v)))
			throw invalid_argument("Fail to set delta spike count vector.");
	}
}

void SecondAlg::set_mpps(const double cor_th){
	ppm_t ppm = cal_by_cor(cor_th);
	set_mpps_by_ppm(ppm);
}


void SecondAlg::set_ps_by_mpps(){
	size_t n = size();
	ps = mpps;
	bool goon = false;
	while(goon){
		goon = false;
		for(size_t i = 0; i < n; ++i){
			for(size_t j = 0; j < n; ++j){
				if(i == j || ps[i].size() == 0 || ps[j].size() == 0)
					continue;
				//indirect: remove indirect links
				if(contains(ps[i], ps[j]) && !equals(ps[i], ps[j])){
					goon = true;
					for(size_t p : ps[j])
						ps[i].erase(find(ps[i].begin(), ps[i].end(), p));
				}
			}
		}
	}
}
//ofstream cout("dsc.txt");
//ofstream fout("cor.txt");
SecondAlg::ppm_t SecondAlg::cal_by_cor(const double threshold){
	size_t n = dh.size();
	ppm_t res;
	res.reserve(n);
//	cout << endl;
	for(size_t i = 0; i < n; ++i){
		//cout << i << " delta spike count:" << endl;
		//for(size_t j = 0; j < dh[i].get_length();++j){
		//	cout <<" "<< dh[i][j];
		//}
		//cout << endl;
		ppm_t::value_type temp(n, false);
		for(size_t j = 0; j < n; ++j){
			if(i == j)
				temp[j] = false;
			else if(abs(dh.pearson_correlation(i, j)) >= threshold)
				temp[j] = true;
			//fout << " " <<fixed<< dh.pearson_correlation(i, j);
		}
		//fout << endl;
		res.push_back(move(temp));
	}
	//fout << endl;
	return res;
}


