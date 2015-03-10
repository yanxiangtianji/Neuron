#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <regex>
#include "FirstAlg.h"
#include "SecondAlg.h"
#include "CompareTopo.h"
#include "AnalyzeTopo.h"
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


void go_real_data(const string base_dir, const int amp2ms, double th){
	int n_c1 = 54, n_c2 = 52;
	vector<string> name_list;
	function<void(const string&)> fun_if = [&](const string& fn_st){
//		infer(fn_st, trans_name(fn_st, "../if/", ""), 30 * amp2ms, 0, int(10.1 * 1000 * amp2ms), 0.1, 10 * amp2ms, 0.1);
		infer2(fn_st, trans_name(fn_st, "../if2/", ""), 30 * amp2ms, 0, int(10.1 * 1000 * amp2ms), 0.2);
	};
	function<void(const vector<string>& name_list)> fun_mg = [&](const vector<string>& name_list){
//		string sub = "if/";
		string sub = "if2/";
		ofstream fout_pg(base_dir + sub+"cue1_prog.txt");
		ofstream fout_if(base_dir + sub+"cue1_prog_if.txt");
		merge_result(19, base_dir + sub, name_list, th, fout_pg, fout_if);
		fout_pg.close();
		fout_if.close();
	};
	//go:
	for(int i = 0; i < n_c1; ++i){
		string fn_st = base_dir + "st/cue1_" + to_string(i) + ".txt";
		name_list.push_back("cue1_" + to_string(i) + ".txt");
//		fun_if(fn_st);
	}
	fun_mg(name_list);
	return;
	name_list.clear();
	for(int i = 0; i < n_c2; ++i){
		string fn_st = base_dir + "st/cue2_" + to_string(i) + ".txt";
		name_list.push_back("st/cue2_" + to_string(i) + ".txt");
		fun_if(fn_st);
	}
	fun_mg(name_list);
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
	vector<string> name_list1;
	for(int i = 0; i < 54; ++i)
		name_list1.push_back("cue1_" + to_string(i) + ".txt");

//	infer2(base_dir2 + "st/cue1_1.txt", base_dir2 + "if2/cue1_1.txt", 200 * 10, 0, 1020 * 10, 0.2);
//	return 0;

	go_real_data(base_dir2,10,0.5);
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

