#include <iostream>
#include <string>
#include <map>
#include <random>
#include "../libRandom/power_law_distribution.hpp"

using namespace std;


void test_pld(){
	using namespace std;
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


int main(){
	test_pld();
	return 0;
}

