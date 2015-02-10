#include <iostream>
#include <fstream>
#include <random>
#include <algorithm>
#include "def.h"
#include "EventQueue.h"
#include "Network.h"
#include "ToolRandom.h"


using namespace std;

void test_eq(){
	EventQueue<int,int> eq;
	eq.push(3, 10);
	eq.push(4, 60);
	eq.push(4, 61);
	eq.push(6, 60);
	while(!eq.empty()){
		auto p = eq.get_n_pop();
		cout << p.first << ' ' << p.second << endl;
	}
}

struct A{
	A(int i) :x(i){ cout << "A " << x << endl; }
	ostream& operator()(){ return cout << x; }
	int x;
};
void test_random(){
	function<void()> fun = [](){
		static A x(4);
		x();
	};
	fun = [](){
		static A x(6);
		x();
	};
	for(int i = 0; i < 3; i++)
		fun();//output "A 6"; "666"
	cout << endl;
	A t(7);
	auto f1 = [&](){ t(); };
	t.x = 8;
	auto f2 = [&](){t(); };
	for(int i = 0; i < 3; i++){
		f1();	f2();
		cout << ' ';
	}//outpur "88 88 88 "
}

mt19937 gen;
template<int ST=0>
int _fun0(){
	static int t = ST;
	return t++;
}
template<typename RES,typename DIS>
function<RES()> _fun1(DIS dis){
	return [](){return static_cast<RES>(1); };
}
template<typename DIS>
typename DIS::result_type _fun2(DIS dis){
	return dis(gen);
}
template<typename RES, class ENG, class DIS>
RES _fun3(DIS dis){
	return static_cast<RES>(dis(gen));
}
template<typename RES, class DIS>
RES _fun4(DIS dis){
	return static_cast<RES>(dis(gen));
}
template<typename RES, class DIS>
function<RES()> _fun5(DIS dis){
//	cout << "bind1: " << dis(gen) << endl;
	return [&](){//error about this capture
		auto t = dis(gen); 
		cout <<"bind2: "<< t << endl;
		return static_cast<RES>(t);
		//return invalid value
	};
}
template<typename RES, typename PAR>
RES _fun7(PAR p){
	return static_cast<RES>(p);
}
void test_bind(){
	typedef normal_distribution<double> dis_t;
	//function<int()> f = RandomTool::bind_gen<int, normal_distribution<double> >(normal_distribution<double>(100.0, 3.0));
	//auto f = RandomTool::bind_gen < int, function<int(mt19937&)> >([](mt19937& p){ return p(); });
	auto dis =dis_t(1, 3);
//	dis(gen);
	auto f = _fun1<int, normal_distribution<double>>(dis);
//	cout << f() << endl;
	auto f2 = _fun2(dis);
//	cout << f2 << endl;
	auto f3 = _fun3<int,mt19937>(dis);
//	cout << f3 << endl;
	auto f4 = _fun4<int>(dis);
//	cout << f4 << endl;
	auto f5 = _fun5<int>(dis_t(1, 3));
//	cout << f5() << endl;//error!
	function<dis_t::result_type()> f6 = bind(dis_t(1, 3), ref(gen));
//	cout << f6() << endl;
	function<dis_t::result_type()> f7 = bind(_fun7<int, dis_t::result_type>, bind(f6));
//	cout << f7() << endl;
	function<dis_t::result_type()> f8 = bind(_fun7<int, dis_t::result_type>, bind(dis_t(1, 3), ref(gen)));
//	cout << f8() << endl;
	function<dis_t::result_type()> f9 = ToolRandom::bind_gen<int>(dis);
//	cout << f9() << endl;
	function<int()> fminb = ToolRandom::bound_min<int>(2,bind(_fun0<0>));
	for(int i = 0; i < 6;++i)	cout << fminb() << ' ';
	cout << endl;
	function<int()> fminmaxb = ToolRandom::bound_minmax<int>(8,12, bind(_fun0<0>));
	for(int i = 6; i < 15; ++i)	cout << fminmaxb() << ' ';
	cout << endl;
	function<int()> f10 = ToolRandom::bind_gen_bmin(17, bind(_fun0<0>));
	for(int i = 15; i < 20; ++i)	cout << f10() << ' ';
	cout << endl;
}

void test_neuron(){
	random_device rd;
	auto fun_basic = [](const tp_t t){return t; };
	Neuron::fun_delay_t fun_f = [&](){return fun_basic(1); };
	neu_ptr_t pn1 = make_shared<Neuron>(1, fun_f);
	neu_ptr_t pn2 = make_shared<Neuron>(2, fun_f);
	neu_ptr_t pn3 = make_shared<Neuron>(3, fun_f);
	neu_ptr_t pn4 = make_shared<Neuron>(4, fun_f);

	Neuron::fun_delay_t fun_1 = [&](){return fun_basic(1); };
	Neuron::fun_delay_t fun_2 = [&](){return fun_basic(2); };
	pn1->add_child(pn2, fun_2);
	pn1->add_child(pn3, fun_2);
	pn2->add_child(pn4, fun_1);
	pn3->add_child(pn4, fun_1);

	Neuron::cb_fire_t cb = [](neu_ptr_t p, const tp_t t){
		cout << p->get_id() << " " << t << endl;
	};

	pn1->reg(cb);	pn2->reg(cb);	pn3->reg(cb);	pn4->reg(cb);

	pn1->receive(0);
	pn2->receive(10);
}

void test_init(const string& fn){
	random_device rd;
	//Neuron::fun_delay_t fun1 = [&](const tp_t mean){
	//	tp_t t=static_cast<tp_t>(normal_distribution<>(mean, 5)(rd));
	//	return max(0, t);
	//};
	//Network n;
	//n.initial(fn,fun1);
}

int main(){
	string base_dir("../data");
//	test_eq();
//	test_random();
	test_bind();
//	test_neuron();
//	test_init(base_dir+"multiparent.txt");
	return 0;
}

