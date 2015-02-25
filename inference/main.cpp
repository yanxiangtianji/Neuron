#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <regex>
#include "FirstAlg.h"
#include "CompareTopo.h"
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
	alg.set_mpps(cor_th, delay_th, delay_acc_rate);
//	alg.output_mpps(cout);

	alg.set_ps_by_mpps();
//	alg.output_ps(cout);
	ofstream fout(fn_inf);
	alg.output_ps(fout);
	fout.close();
}

void go_real_data(const string base_dir, const int amp2ms){
	int n_c1 = 54, n_c2 = 51;
	for(int i = 0; i < 1; ++i){
		string fn_st = base_dir + "st/cue1_" + to_string(i) + ".txt";
		string fn_inf = trans_name(fn_st, "../if/", "");
		infer(fn_st, fn_inf, 30 * amp2ms, 0, int(10.1 * 1000 * amp2ms), 0.6, 10 * amp2ms, 0.8);
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
	vector<string> test_files{ "sparent.txt", "mparent.txt", "indirect1.txt", "indirect2.txt", "common1.txt",
		"common2.txt", "common3.txt", "big100.txt", "big25.txt", "big10.txt" };
//	test(base_dir); return 0;

	string base = base_dir + "real/";
	go_real_data(base,10);

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

