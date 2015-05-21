#include <iostream>
#include <fstream>
#include <random>
#include <map>
#include <string>
#include <algorithm>
#include "AdjGraph.h"
#include "AdjGraphSec.h"
#include "generate.h"
#include "GeneratorDegree.h"

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

void test_gen_degree(){
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

void test_check(){
	GeneratorDegree gend(4, GeneratorDegree::DegreeType::OUTDEGREE, false, false);
	cout << "ok: upper bound" << endl;
	AdjGraph g = gend.gen({0,1,2,3});
	cout << "ok: normal" << endl;
	g = gend.gen({ 0, 0, 1, 2 });
	cout << "problem: max degree" << endl;
	try{
		g = gend.gen({ 0, 4, 1, 2 });
	} catch(exception& e){
		cerr << e.what() << endl;
	}
	cout << "problem: distribution" << endl;
	try{
		g = gend.gen({ 3, 1, 1, 2 });
	} catch(exception& e){
		cerr << e.what() << endl;
	}
}

void test_nl_gen(){
	GeneratorDegree gend(4, GeneratorDegree::DegreeType::OUTDEGREE, false);
	AdjGraph g = gend.gen_nloop({0,1,2,3});
	cout << g.sort_up() << endl;
	g=gend.gen_nloop({ 0, 1, 0, 3 });
	cout << g.sort_up() << endl;
}

void test_distribution(){
	GeneratorDegree gend(6, GeneratorDegree::DegreeType::OUTDEGREE, false);
	mt19937 rgen(69);
	auto ung = uniform_int_distribution<size_t>(0, 5);
	function<size_t(const size_t)> int_dis = [&](const size_t nid){return ung(rgen); };
	AdjGraph g = gend.gen(int_dis, true);
	cout << g.sort_up() << endl;
	auto nng = normal_distribution<double>(0, 4);
	function<double()> double_dis = [&](){return abs(nng(rgen)); };
	g = gend.gen(8,double_dis,true);
	cout << g.sort_up() << endl;
}

void go(const size_t n,const string& fn,const vector<size_t>& vec){
	cout << fn << endl;
	AdjGraph g = gen_tp_degree(false, n, vec);
	ofstream fout(fn);
	fout << g.sort_up();
	fout.close();
}
void go2(const size_t n, const string& fn, const vector<size_t>& vec){
	cout << fn << endl;
	GeneratorDegree gend(n, GeneratorDegree::DegreeType::OUTDEGREE, false);
	AdjGraph g = gend.gen(vec);
//	ofstream fout(fn);
	cout << g.sort_up() << endl;
//	fout.close();
}

void go3(const size_t n, const string& fn){
	GeneratorDegree gend(n, GeneratorDegree::DegreeType::OUTDEGREE, false);
	mt19937 rg;
	uniform_int_distribution<size_t> udis(0, n - 1);
	function<size_t()> ugen = bind(udis, rg);
	AdjGraph g = gend.gen(ugen, true);
	ofstream fout(fn);
	fout << g.sort_up();
	fout.close();
}

void go4(const size_t n, const string& fn){
	GeneratorDegree gend(n, GeneratorDegree::DegreeType::OUTDEGREE, false);
	mt19937 rg;
	auto nng = normal_distribution<double>(0, n/4.0);
	function<size_t()> int_dis = [&](){
		return min(n-1, static_cast<size_t>(abs(nng(rg))));
	};
	//map<size_t, size_t> m;
	//for(size_t i = 0; i < 100000; i++){
	//	++m[int_dis()];
	//}
	//for(auto& p : m){
	//	cout << p.first << '\t' << p.second << endl;
	//}
//	return;
	AdjGraph g = gend.gen(int_dis, true);
	ofstream fout(fn);
	fout << g.sort_up();
	fout.close();
}

int main(){
	string base_dir("../data/");
//	test_graph();
//	test_gen_degree();
//	test_check();
//	test_nl_gen();
//	test_distribution();
//	go2(2, base_dir + "sparent.txt", { 0, 1 });
	//go(4, base_dir + "mparent.txt", { 0, 0, 0, 3 });
	//go(3, base_dir + "indirect1.txt", { 0, 1, 1 });
//	go2(4, base_dir + "indirect2.txt", { 0, 0, 1, 3 });
	//go(3, base_dir + "common1.txt", { 0,1,1});
	//go(4, base_dir + "common2.txt", { 0, 0, 2, 2 });
	//go3(100, base_dir + "big100.txt");
	//go3(25, base_dir + "big25.txt");
	go4(10, base_dir + "big10.txt");
	return 0;
}