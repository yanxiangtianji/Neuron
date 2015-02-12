#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include "../libCorrelation/DataHolderBinary.h"
#include "../libCorrelation/def.h"
#include "FirstAlg.h"

using namespace std;

void test_bin_cor(const string& fn){
	cout << fn << endl;
	DataHolderBinary dh(20,0,1020,fn);
	size_t n = dh.size();
	for(size_t i = 0; i < n; ++i){
		for(size_t j = 0; j < n; ++j){
			cout << '\t' << dh.cor_dp(i,j);
		}
		cout << endl;
	}
	cout << "-------" << endl;
	for(size_t i = 0; i < n; ++i){
		for(size_t j = 0; j < n; ++j){
			cout << '\t' << dh.cor_dp_f(i, j);
		}
		cout << endl;
	}
}

void test_mpps(const string& fn){
	cout << fn << endl;
	FirstAlg alg(20, 0, 1020,fn);
	size_t n = alg.size();
	alg.set_mpps(0.6,3);
	auto& mpps = alg.get_mpps();
	for(size_t i = 0; i < n;++i){
		cout << i << '\n';
		for(auto& pid : mpps[i]){
			cout << ' ' << pid;
		}
		cout << endl;
	}
}

void test_ps(const string& fn){
	cout << fn << endl;
	FirstAlg alg(20, 0, 1020, fn);
	size_t n = alg.size();
	alg.set_mpps(0.6, 3);
	cout << "mpps:" << endl;
	auto& mpps = alg.get_mpps();
	for(size_t i = 0; i < n; ++i){
		cout << i << '\n';
		for(auto& pid : mpps[i]){
			cout << ' ' << pid;
		}
		cout << endl;
	}
	cout << "ps:" << endl;
	alg.set_ps_by_mpps();
	alg.output_ps(cout);
}

void go(const string& fn, const tp_t window_size, const tp_t start, const tp_t end,
	const double cor_th, const tp_t delay_th)
{
	cout << fn << endl;
	string fn_st = fn;
	fn_st.replace(fn.rfind('.'), 1, "_st.");
	FirstAlg alg(window_size, start, end, fn_st);
	size_t n = alg.size();
	alg.set_mpps(cor_th, delay_th);
	alg.set_ps_by_mpps();
	string fn_inf = fn;
	fn_inf.replace(fn.rfind('.'), 1, "_if.");
	ofstream fout(fn_inf);
	alg.output_ps(fout);
	fout.close();
}

int main(int argc, char* argv[])
{
	string base_dir("../data/");
	vector<string> test_files{ "sparent.txt", "mparent.txt", "indirect1.txt", "indirect2.txt", "common1.txt", "common2.txt" };
//	test_bin_cor(base_dir+"mparent_st.txt");
//	test_mpps(base_dir + "mparent_st.txt");
//	test_ps(base_dir + "indirect1_st.txt");
	for(size_t i = 0; i < test_files.size(); ++i)
	{
		go(base_dir+test_files[i], 20, 0, 1020, 0.6, 3);
	}
	return 0;
}

