#include "test_eval.h"
#include "pld_eval_test.hpp"
#include <random>
#include <chrono>
#include <iostream>

using namespace std;

void _test_rnd_speed(){
	mt19937 g;
	const int NUM = 99999999;
	pld_store_urng<double> sgen;
	auto t1 = chrono::system_clock::now().time_since_epoch().count();
	for(int i = 0; i < NUM; ++i)
		sgen(g);
	t1 = chrono::system_clock::now().time_since_epoch().count() - t1;

	pld_dyn_urng<double> dgen;
	auto t2 = chrono::system_clock::now().time_since_epoch().count();
	for(int i = 0; i < NUM; ++i)
		dgen(g);
	t2 = chrono::system_clock::now().time_since_epoch().count() - t2;
	cout << "store:  \t" << t1 << endl;//faster in debug mode
	cout << "dynamic:\t" << t2 << endl;//almost the same in release mode (sometimes even little faster)
}

void test_rnd_speed(const size_t n){
	for(size_t i = 0; i < n;i++)
		_test_rnd_speed();

}