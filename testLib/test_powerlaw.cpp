#include "test_powerlaw.h"
#include "../libRandom/power_law_distribution.hpp"
#include "../libRandom/degree_pl_distribution.hpp"
#include <map>
#include <iostream>
#include <string>

using namespace std;

void test_pld(){
	power_law_distribution<double> p(1, 2.5);
	cout << p.min() << "\t" << p.max() << endl;
	cout << p.xmin() << "\t" << p.alpha() << endl;
	mt19937 gen;
	map<int, int> m;
	for(int i = 0; i < 10000; i++){
		double x = p(gen);
		int t = (int)(x * 10);
		++m[t];
	}
	int slot = 20;
	for(auto& p : m){
		cout << p.first << '\t' << string(p.second / slot, '*') << endl;
		if(p.second < slot)
			break;
	}
}

int max(int a,int b){
	return a>b ? a : b;
}

void test_degree_pl(const size_t n,const double alpha){
//	degree_pl_distribution<double> _dis(10,2.5);	//static error
	degree_pl_distribution<size_t> dis(n, alpha);
	mt19937 gen;
	map<size_t, int> m;
	for(int i = 0; i < 10000; i++){
		auto t = dis(gen);
		++m[t];
	}
	int slot = max(40, 500 / n);
	for(auto& p : m){
		if(p.second < slot)
			continue;
		cout << p.first << '\t' << string(p.second / slot, '*') << endl;
	}
	cout << endl;
}

