#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <regex>
#include "FirstAlg.h"
#include "SecondAlg.h"
#include "CompareTopo.h"
#include "AnalyzeTopo.h"
#include "OnRealData.h"
#include "test.h"

using namespace std;

string trans_name(const string& base, const string& prefix, const string& suffix){
	static regex reg(R"(([^/]+?)\.([^\.]+?)$)", regex::ECMAScript | regex::optimize);
	return regex_replace(base, regex(R"(([^/]+?)\.([^\.]+?)$)"), prefix + "$1" + suffix + ".$2");
}

void infer(const string& fn_st, const string& fn_inf,
	const tp_t window_size, const tp_t start, const tp_t end,
	const double cor_th, const tp_t delay_th, const double delay_acc_rate)
{
	cout << fn_st << endl;
	FirstAlg alg(window_size, start, end, fn_st);
	size_t n = alg.size();
	alg.set_mpps_param(delay_th, delay_acc_rate);
	alg.set_mpps(cor_th);
//	alg.output_mpps(cout);

	alg.set_ps_by_mpps();
//	alg.output_ps(cout);
	ofstream fout(fn_inf);
	alg.output_ps(fout);
	fout.close();
}

void infer2(const string&fn_st, const string& fn_inf,
	const tp_t window_size, const tp_t start, const tp_t end, const double cor_th)
{
	cout << fn_st << endl;
	SecondAlg alg(window_size, start, end, fn_st);
	size_t n = alg.size();
	alg.set_mpps(cor_th);
//	alg.output_mpps(cout);

	alg.set_ps_by_mpps();
//	alg.output_ps(cout);
	ofstream fout(fn_inf);
	alg.output_ps(fout);
	fout.close();
}

AnalyzeTopo::adj_g_t _load_adj(const string& fn){
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

void merge_result(const size_t n, const string& base_dir, const vector<string>& name_list,
	const double threshold, ostream& os_mat, ostream& os_if)
{
	AnalyzeTopo anl(n);
	for(auto& fn : name_list){
		anl.add(_load_adj(base_dir + fn));
	}
	auto pg = anl.get_prob_g();
	os_mat.precision(4);
	os_if << n << "\n";
	for(size_t i = 0; i < n; i++){
		const vector<double>& line = pg[i];
		vector<size_t> list;
		for(size_t j = 0; j < n; ++j){
			os_mat << '\t' << line[j];
			if(line[j] >= threshold)
				list.push_back(j);
		}
		os_mat << '\n';
		os_if << i << ' ' << list.size() << '\n';
		for(size_t t : list)
			os_if << ' ' << t;
		os_if << '\n';
	}
}

void merge_result_mat(const size_t n, const vector<vector<size_t> >& mat,
	const double threshold, ostream& os_mat, ostream& os_if)
{
	os_mat.precision(4);
	os_if << n << "\n";
	for(size_t i = 0; i < n; ++i){
		vector<size_t> temp;
		for(size_t j = 0; j < n; ++j){
			double v = double(mat[i][j]) / n;
			os_mat << '\t' << v;
			if(v >= threshold)
				temp.push_back(j);
		}
		os_mat << '\n';
		os_if << i << ' ' << temp.size() << '\n';
		for(size_t t : temp)
			os_if << ' ' << t;
		os_if << '\n';
	}
}


void go_real_data(const string base_dir, const string res_suf,
	const string& st_fld, const string& if_fld, const int amp2ms, double cor_th, double prob_th)
{
	const int n_c1 = 54, n_c2 = 52;
	function<void(const string&)> fun_if = [&](const string& fn_st){
		string st_f = base_dir + st_fld + fn_st;
		string if_f = base_dir + if_fld + fn_st;
//		infer(st_f, if_f, 50 * amp2ms, 0, int(10.1 * 1000 * amp2ms), 0.1, 10 * amp2ms, 0.1);
		infer2(st_f, if_f, 200 * amp2ms, 0, int(10.1 * 1000 * amp2ms), cor_th);
	};
	function<void(const string& fn_head, const vector<string>& name_list)> fun_mg
		= [&](const string& fn_head, const vector<string>& name_list)
	{
		ofstream fout_pg(base_dir + if_fld + fn_head + ".txt");
		ofstream fout_if(base_dir + if_fld + fn_head + "_if.txt");
		merge_result(19, base_dir + if_fld, name_list, prob_th, fout_pg, fout_if);
		fout_pg.close();
		fout_if.close();
	};
	//go:
	vector<string> name_list;
	for(int i = 0; i < n_c1; ++i){
		string fn_st = "cue1_" + to_string(i) + ".txt";
		name_list.push_back(fn_st);
		fun_if(fn_st);
	}
	fun_mg("cue1_" + res_suf, name_list);
//	return;
	name_list.clear();
	for(int i = 0; i < n_c2; ++i){
		string fn_st = "cue2_" + to_string(i) + ".txt";
		name_list.push_back(fn_st);
		fun_if(fn_st);
	}
	fun_mg("cue2_" + res_suf, name_list);
}


void go_real_data_no_mid(const string base_dir, const string res_suf,
	const string& st_fld, const string& if_fld, const int amp2ms,double cor_th, double prob_th)
{
	const int n_c1 = 54, n_c2 = 52;
	function<const AlgBase::pss_t&(const string&)> fun_if = [&](const string& fn_st)->const AlgBase::pss_t&{
		string st_f = base_dir + st_fld + fn_st;
//		string if_f = base_dir + if_fld + fn_st;
//		infer(st_f, if_f, 50 * amp2ms, 0, int(10.1 * 1000 * amp2ms), 0.1, 10 * amp2ms, 0.1);
//		infer2(st_f, if_f, 200 * amp2ms, 0, int(10.1 * 1000 * amp2ms), 0.2);
		SecondAlg alg(200 * amp2ms, 0, int(10.1 * 1000 * amp2ms), st_f);
		alg.set_mpps(cor_th);
		alg.set_ps_by_mpps();
		return alg.get_ps();
	};
	function<void(const string&, const vector<vector<size_t> >&, const int)> fun_mg
		= [&](const string& fn_head, const vector<vector<size_t> >& mat, const int n_trial)
	{
		ofstream fout_pg(base_dir + if_fld + fn_head + ".txt");
		ofstream fout_if(base_dir + if_fld + fn_head + "_if.txt");
		merge_result_mat(n_trial, mat, prob_th, fout_pg, fout_if);
		fout_pg.close();
		fout_if.close();
	};
	//go:
	vector<vector<size_t> > mat;
	for(int i = 0; i < n_c1; ++i){
		string fn_st = "cue1_" + to_string(i) + ".txt";
		const AlgBase::pss_t& temp = fun_if(fn_st);
		if(mat.empty())
			mat.resize(temp.size(), vector<size_t>(temp.size()));
		for(size_t i = 0; i < temp.size(); ++i) {
			for(auto& id : temp[i]){
				++mat[i][id];
			}
		}
	}
	fun_mg("cue1_" + res_suf, mat, n_c1);
	//	return;
	mat.clear();
	for(int i = 0; i < n_c2; ++i){
		string fn_st = "cue2_" + to_string(i) + ".txt";
		const AlgBase::pss_t& temp = fun_if(fn_st);
		if(mat.empty())
			mat.resize(temp.size(), vector<size_t>(temp.size()));
		for(size_t i = 0; i < temp.size(); ++i) {
			for(auto& id : temp[i]){
				++mat[i][id];
			}
		}
	}
	fun_mg("cue2_" + res_suf, mat, n_c2);
}

void go_real_data_multi_parameter(const string base_dir,
	const string& st_fld, const string& if_fld, const int amp2ms, 
	vector<double> cor_th, vector<double> prob_th)
{
	for(double c_th : cor_th){
		for(double p_th : prob_th){
			go_real_data_no_mid(base_dir, "_c" + to_string(c_th) + "_p" + to_string(p_th),
				st_fld, if_fld, amp2ms, c_th, p_th);
		}
	}
}

void compare(const string& base_fn, const string& suffix){
	cout << base_fn << "\t" << suffix << endl;
	CompareTopo cmp(base_fn);
	string fn2 = base_fn;
	fn2.replace(fn2.rfind('.'), 1, suffix + ".");
	auto cm = cmp.cmatrix(cmp.compare(fn2));
	cout << "\tR=t\tR=f" << endl;
	cout << "P=t\t" << cm.tp << '\t' << cm.tn<<'\t'<<cm.predict_t() << endl;
	cout << "P=f\t" << cm.fn << '\t' << cm.fp<<'\t'<<cm.predict_f() << endl;
	cout << "\t"<<cm.real_t()<<'\t'<<cm.real_f()<<'\t'<<cm.total()<<endl;

	auto scores = cmp.scores(cm);
	cout << "precision=" << scores.precision << endl;
	cout << "recall=" << scores.recall << endl;
	cout << "f1=" << scores.f1 << endl;
	cout << "accurancy=" << scores.accurancy << endl;

}


int main(int argc, char* argv[])
{
	string base_dir("../data/");
	string base_dir2(base_dir + "real/");
//	test(base_dir); return 0;
	vector<string> test_files{ "sparent.txt", "mparent.txt", "indirect1.txt", "indirect2.txt", "common1.txt",
		"common2.txt", "common3.txt", "big100.txt", "big25.txt", "big10.txt" };

//	infer2(base_dir2 + "st/cue1_1.txt", base_dir2 + "if2/cue1_1.txt", 200 * 10, 0, 1020 * 10, 0.2);
//	return 0;

	const int n_c1 = 54, n_c2 = 52;
	vector<string> cue1_list, cue2_list;
	for(int i = 0; i < n_c1; ++i)
		cue1_list.push_back("cue1_" + to_string(i) + ".txt");
	for(int i = 0; i < n_c2; ++i)
		cue2_list.push_back("cue2_" + to_string(i) + ".txt");

	OnRealData real(base_dir2, 10, 19);
	real.set_time_start(0);
	real.set_time_end(1000);
	function<void(const string&, const string&, const string&, double, double)> go_mid =
		[&](const string& head, const string& st_fld, const string& if_fld, double cor_th, double pro_th)
	{
		real.set_st_fld(st_fld);
		real.set_if_fld(if_fld);
		real.go_mid("cue1_" + head, cue1_list, cor_th, pro_th);
		real.go_mid("cue2_" + head, cue2_list, cor_th, pro_th);
	};
//	go_mid("prob", "st/", "if2", 0.2, 0.5);
//	go_mid("prob", "st0-3/", "if2_0-3/", 0.2, 0.5);
//	go_mid("prob", "st3-6/", "if2_3-6/", 0.2, 0.5);
//	go_mid("prob", "st6-9/", "if2_6-9/", 0.2, 0.5);
//	return 0;
	function<void(const string&, const string&, const string&, const vector<double>&, const vector<double>&)> go_multi =
		[&](const string& head, const string& st_fld, const string& if_fld, const vector<double>& cor_ths, const vector<double>& pro_ths)
	{
		real.set_st_fld(st_fld);
		real.set_if_fld(if_fld);
		real.go_multi_parameter("cue1_" + head, cue1_list, cor_ths, pro_ths);
		//real.go_multi_parameter("cue2_" + head, cue2_list, cor_ths, pro_ths);
	};
	go_multi("prob", "st0-3/", "if2_0-3m/", { 0.2, 0.4, 0.6, 0.8 }, { 0.2, 0.4, 0.6, 0.8 });
	return 0;

//	infer(base_dir + "big100.txt", "_st2", 20, 0, 1040, 0.6, 8, 0.8);
//	for(size_t i = 0; i < test_files.size(); ++i)
	for(size_t i = 8; i < 9; ++i)
	{
//		infer(base_dir + test_files[i], "_st", 20, 0, 1040, 0.6, 8, 0.8);
		compare(base_dir + test_files[i], "_st_if");
		cout << endl;
//		infer(base_dir + test_files[i], "_st2", 20, 0, 1040, 0.6, 8, 0.8);
		compare(base_dir + test_files[i], "_st2_if");
	}
	return 0;
}

