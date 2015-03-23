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
		real.go_batch("cue1_" + head, cue1_list, true, cor_th, pro_th);
		real.go_batch("cue2_" + head, cue2_list, true, cor_th, pro_th);
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
		real.go_multi_parameter("cue2_" + head, cue2_list, cor_ths, pro_ths);
	};
	go_multi("prob", "st0-3/", "if2_0-3m/", { 0.2, 0.4, 0.6, 0.8 }, { 0.2, 0.4, 0.5, 0.6, 0.8 });
	go_multi("prob", "st3-6/", "if2_3-6m/", { 0.2, 0.4, 0.6, 0.8 }, { 0.2, 0.4, 0.5, 0.6, 0.8 });
	go_multi("prob", "st6-9/", "if2_6-9m/", { 0.2, 0.4, 0.6, 0.8 }, { 0.2, 0.4, 0.5, 0.6, 0.8 });
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

