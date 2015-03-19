#include "OnRealData.h"
#include <string>
#include <fstream>
#include <iostream>
#include <vector>
#include <functional>
#include "AnalyzeTopo.h"
#include "FirstAlg.h"
#include "SecondAlg.h"

using namespace std;

#ifdef _WIN32
ofstream F_DUMMY("nul");
#else
ofstream F_DUMMY("/dev/null");
#endif

OnRealData::OnRealData(const std::string base_dir, const size_t amp2ms, const size_t n_node)
	:base_dir(base_dir), amp2ms(amp2ms), n_node(n_node)
{
}



AnalyzeTopo::adj_g_t OnRealData::_load_adj(const string& fn){
	ifstream fin(fn);
	size_t n;
	fin >> n;
	AnalyzeTopo::adj_g_t res(n);
	for(size_t i = 0; i < n; ++i){
		size_t id, m;
		fin >> id >> m;
		for(size_t j = 0; j < m; ++j){
			size_t t;
			fin >> t;
			res[id].push_back(t);
		}
	}
	return res;
}

AlgBase::pss_t OnRealData::_infer(const string& fn_st, const bool out_if, const double cor_th)
{
	int window_size = 200;
	string st_f = base_dir + st_fld + fn_st;
//		infer(st_f, if_f, 50 * amp2ms, 0, int(1.01 * 1000 * amp2ms), 0.1, 10 * amp2ms, 0.1);
/*	FirstAlg alg(window_size*amp2ms, time_start, time_end, fn_st);
	alg.set_mpps_param(10 * amp2ms, 0.1);
	alg.set_mpps(cor_th);
	alg.set_ps_by_mpps();*/
//		infer2(st_f, if_f, 200 * amp2ms, 0, int(1.01 * 1000 * amp2ms), 0.2);
	SecondAlg alg(window_size * amp2ms, time_start, int(1.01 * time_end * amp2ms), st_f);
	alg.set_mpps(cor_th);
	alg.set_ps_by_mpps();
	if(out_if){
		string if_f = base_dir + if_fld + fn_st;
		ofstream fout(if_f);
		alg.output_ps(fout);
		fout.close();
	}
	return alg.get_ps();
}

void OnRealData::output_merged_result(const AnalyzeTopo& anl,
	const double prob_th, ostream& os_mat, ostream& os_if)
{
	output_merged_result(anl.get_prob_g(), prob_th, os_mat, os_if);
}
void OnRealData::output_merged_result(const AnalyzeTopo::prob_g_t& pmat,
	const double prob_th, ostream& os_mat, ostream& os_if)
{
	os_mat.precision(4);
	os_if << n_node << "\n";
	for(size_t i = 0; i < n_node; ++i){
		vector<size_t> temp;
		for(size_t j = 0; j < n_node; ++j){
			double v = pmat[i][j];
			os_mat << '\t' << v;
			if(v >= prob_th)
				temp.push_back(j);
		}
		os_mat << '\n';
		os_if << i << ' ' << temp.size() << '\n';
		for(size_t t : temp)
			os_if << ' ' << t;
		os_if << '\n';
	}
}


void OnRealData::go_batch(const string& res_head, const std::vector<std::string>& name_list,
	const bool with_mid, const double cor_th, const double prob_th)
{
	//infer:
	AnalyzeTopo anl(n_node);
	for(size_t i = 0; i < name_list.size(); ++i){
		cout << name_list[i] << endl;
		anl.add(_infer(name_list[i], with_mid, cor_th));
	}
	//merge:
	ofstream fout_pg(base_dir + if_fld + res_head + ".txt");
	ofstream fout_if(base_dir + if_fld + res_head + "_if.txt");
	output_merged_result(anl, prob_th, fout_pg, fout_if);
	fout_pg.close();
	fout_if.close();
}

void OnRealData::go_multi_parameter(const string& res_head, const vector<string>& name_list,
	const vector<double>& cor_ths, const vector<double>& prob_ths)
{
#ifdef _WIN32
#define my_sprintf sprintf_s
#else
#define my_sprintf snprintf
#endif
	for(double c_th : cor_ths){
		//infer:
		AnalyzeTopo anl(n_node);
		for(size_t i = 0; i < name_list.size(); ++i){
			cout << name_list[i] << endl;
			anl.add(_infer(name_list[i], false, c_th));
		}
		char str_c[10];
		my_sprintf(str_c, 10, "%.2lf", c_th);
		ofstream fout_pg(base_dir + if_fld + res_head + "_c" + str_c + ".txt");
		output_merged_result(anl, 0.0, fout_pg, F_DUMMY);
		fout_pg.close();
		//merge:
		for(double p_th : prob_ths){
			//go_batch(res_head + "_c" + to_string(c_th) + "_p" + to_string(p_th), name_list, false, c_th, p_th);
			char str_p[10];
			my_sprintf(str_p, 10, "%.2lf", p_th);
			//go_batch(res_head + "_c" + str_c + "_p" + str_p, name_list, false, c_th, p_th);
			ofstream fout_if(base_dir + if_fld + res_head + "_c" + str_c + "_p" + str_p+".txt");
			output_merged_result(anl, p_th, F_DUMMY, fout_if);
			fout_if.close();

		}
	}
#undef my_sprintf
}

