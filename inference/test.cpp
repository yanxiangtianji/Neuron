#include "test.h"
#include <iostream>
#include <string>
#include <regex>
#include "../libCorrelation/DataHolderBinary.h"
#include "FirstAlg.h"
#include "CompareTopo.h"

using namespace std;

void test_bin_cor(const string& fn){
	cout << fn << endl;
	DataHolderBinary dh(20, 0, 1020, fn);
	size_t n = dh.size();
	for(size_t i = 0; i < n; ++i){
		for(size_t j = 0; j < n; ++j){
			cout << '\t' << dh.cor_dp(i, j);
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
	FirstAlg alg(20, 0, 1020, fn);
	size_t n = alg.size();
	alg.set_mpps(0.6, 3, 0.8);
	auto& mpps = alg.get_mpps();
	for(size_t i = 0; i < n; ++i){
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
	alg.set_mpps(0.6, 3, 0.8);
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

void test_cmp(const string& fn, const string& suffix){
	cout << fn << endl;
	CompareTopo cmp(fn);
	string fn2 = fn;
	fn2.replace(fn2.rfind('.'), 1, suffix + ".");
	auto res = cmp.compare(fn2);
	auto cm = cmp.cmatrix(res);
	auto scores = cmp.scores(cm);
	cout << "\tR=t\tR=f" << endl;
	cout << "P=t\t" << cm.tp << '\t' << cm.tn << '\t' << cm.predict_t() << endl;
	cout << "P=f\t" << cm.fn << '\t' << cm.fp << '\t' << cm.predict_f() << endl;
	cout << "\t" << cm.real_t() << '\t' << cm.real_f() << '\t' << cm.total() << endl;

	cout << "precision=" << scores.precision << endl;
	cout << "recall=" << scores.recall << endl;
	cout << "f1=" << scores.f1 << endl;
	cout << "accurancy=" << scores.accurancy << endl;
}

void test_regex(){
	string base[] = { 
		"../data/file.txt",
		"data/a.b.file.txt",
		"file.txt",
		"D:/My Program/Projects/Neurondata/real/file.txt" };
	regex reg(R"(([^/]+?)\.([^\.]+?)$)");
	smatch m;
	for(const auto& line : base){
		cout << regex_search(line, reg)<<" in "<<line << endl;
		regex_search(line, m, reg);
		for(size_t i = 0; i < m.size(); ++i){
			std::ssub_match sub_match = m[i];
			std::cout << i << ": " << sub_match.str() << '\n';
		}
		for(auto& sm : m){
			cout << sm.str() << endl;
		}
	}
	cout << endl;
	for(auto& line : base){
		cout << regex_replace(line, reg, "my_$1_ext.$2") << endl;
	}
}


void test(const string base_dir){
//	test_bin_cor(base_dir+"mparent_st.txt");
//	test_mpps(base_dir + "mparent_st.txt");
//	test_ps(base_dir + "indirect1_st.txt");
//	test_cmp(base_dir + "indirect2.txt", "_st_if");
//	test_cmp(base_dir + "big10.txt", "_st2_if");
	test_regex();
}

