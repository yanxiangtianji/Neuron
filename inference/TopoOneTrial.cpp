#include "TopoOneTrial.h"
#include "SecondAlg.h"
#include "FirstAlg.h"

using namespace std;

TopoOneTrial::TopoOneTrial(const std::string& fn, const int t_start, const int t_end,
	const int period, const int t_window, const int amp2ms)
	:fn(fn), time_start(t_start), time_end(t_end), period(period), time_window(t_window), amp2ms(amp2ms)
{
}

void TopoOneTrial::gen_static_structure(){
	size_t n = cont[0].size();
	vector<vector<bool>> mat(n, vector<bool>(n));
	for(size_t idx = 0; idx < cont.size(); ++idx){
		for(size_t i = 0; i < n; ++i){
			for(auto v : cont[idx][i])
				mat[i][v] = true;
		}
	}
	static_s.clear();
	for(size_t i = 0; i < n; ++i){
		vector<size_t> ps;
		for(size_t j = 0; j < n; ++j)
			if(mat[i][j])
				ps.push_back(j);
		static_s.push_back(move(ps));
	}
}

AlgBase::pss_t TopoOneTrial::infer(const size_t idx){
//	FirstAlg alg(time_window*amp2ms, amp2ms*(time_start + idx*period), amp2ms*(time_start + (idx + 1)*period), fn);
//	alg.set_mpps_param(amp2ms * 15, 0.15);
	SecondAlg alg(time_window * amp2ms,	amp2ms*(time_start + idx*period),
		amp2ms*(time_start + (idx+1)*period), fn);
	alg.set_mpps(cor_th);
	alg.set_ps_by_mpps();
	return alg.get_ps();
}

void TopoOneTrial::go(){
	size_t n = size();
	cont.clear();
	for(size_t i = 0; i < n; ++i){
		cont.push_back(infer(i));
	}
}
