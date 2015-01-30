#include <iostream>
#include <fstream>
#include <random>
#include "AdjGraph.h"
#include "AdjGraphSec.h"
#include "generate.h"

using namespace std;

void test_graph(){
	cout << "hello" << endl;
	AdjGraph g(10);
	for(int i = 0; i < 10; i++){
		g.add(i, i % 10);
	}
	g.sort_up();
	cout << g << endl;
	cout << "other" << endl;
	AdjGraphSec gs(10);
	for(int i = 0; i < 10; i++){
		gs.add(i, (i + 1) % 10);
	}
	cout << "again" << endl;
	cout << gs << endl;
	for(int i = 0; i < 10; i++){
		gs.add(i, i % 10);
		gs.add(i, (i + 2) % 10);
	}
	gs.add(1, 2);
	gs.add(3, 3);
	cout << gs << endl;
}

void test_gen(){
	size_t n = 10;
	//AdjGraph g1 = gen_tp_degree(false, n, {1,2,3,4,5,6,7,8,9,0});
	//g1.sort_up();
	//cout << g1 << endl;
	random_device rd;
	uniform_int_distribution<size_t> u_dis(0, n - 1);
	auto fu = [&](const size_t)->size_t{return u_dis(rd); };
	//AdjGraph g2 = gen_tp_degree(false, n, fu);
	//cout << g2.sort_up() << endl;
	normal_distribution<> n_dis(4, 2);
	auto fn = [&](){return n_dis(rd); };
	AdjGraph g3 = gen_tp_degree(false, n*10,650, [&](const size_t){return fn(); });
//	cout << g3.sort_up() << endl;
	cout << g3.get_n() << ' ' << g3.get_m() << endl;
}

int main(){
//	test_graph();
	test_gen();
	return 0;
}