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

	pn1->reg_cb_f(cb);	pn2->reg_cb_f(cb);	pn3->reg_cb_f(cb);	pn4->reg_cb_f(cb);

	pn1->receive(0);
	pn2->receive(10);
}

void test_init(const string& fn){
	typedef normal_distribution<double> n_dis_t;
	typedef uniform_int_distribution<int> u_dis_t;
	Network::metafun_fire_sh_t mf_fire_sh = [](const nid_t&)->signal_t{return 0; };
	Network::metafun_fire_d_t mf_fire_d = [](const nid_t&){return Neuron::get_default_fun_delay(); };
	Network::metafun_prog_d_t mf_prog_d = [](const nid_t&, const nid_t&){return Neuron::get_default_fun_delay(); };
	Network n;
	n.initial(fn,mf_fire_sh,mf_fire_d,mf_prog_d);
	for(size_t i = 0; i < n.size(); ++i){
		auto p = n.get(i);
		cout << p->get_fun_delay_f()() << " ";
	}
	cout << endl;

	Network::metafun_fire_d_t mf_fire_d1 = [](const nid_t&){return [](){return 1; }; };
	Network::metafun_prog_d_t mf_prog_d1 = [](const nid_t&, const nid_t&){return [](){return 4; }; };
	Network n1;
	n1.initial(fn, mf_fire_sh, mf_fire_d1, mf_prog_d1);
	for(size_t i = 0; i < n1.size(); ++i){
		auto p = n1.get(i);
		cout << p->get_fun_delay_f()() << " ";
	}
	cout << endl;

	Network::metafun_fire_d_t mf_fire_d2 = [](const nid_t&){return ToolRandom::bind_gen_bmin(0,n_dis_t(5,2)); };
	Network::metafun_prog_d_t mf_prog_d2 = [](const nid_t&, const nid_t&){
		int mean = ToolRandom::get_int(7, 14);
		return ToolRandom::bind_gen_bmin(0, n_dis_t(mean, 3)); 
	};
	Network n2;
	n2.initial(fn, mf_fire_sh, mf_fire_d2, mf_prog_d2);
	for(size_t i = 0; i < n2.size(); ++i){
		auto p = n2.get(i);
		cout << p->get_fun_delay_f()() << " ";
	}
	cout << endl;
}

void test_spike(const string& fn){
	Network::metafun_fire_sh_t mf_fire_sh = [](const nid_t&)->signal_t{return 0; };
	Network::metafun_fire_d_t mf_fire_d = [](const nid_t&){return [](){return 1; }; };
	Network::metafun_prog_d_t mf_prog_d = [](const nid_t&, const nid_t&){return [](){return 4; }; };
	Network n;
	n.initial(fn, mf_fire_sh);
	n.output_structure(cout);
	cout << "---first---" << endl;
//	Network::spike_trains_t ts=n.gen_spikes(4);
//	n.record_spikes(cout, ts);
	cout << "---second---" << endl;
	Network::spike_trains_t ts2(n.size());
	ts2[0].push_back(1);
	ts2[0].push_back(1);
	ts2[0].push_back(2);
	ts2[1].push_back(8);
	ts2[2].push_back(20);
	ts2[3].push_back(30);
	n.record_spikes(cout, ts2);
	cout << "------" << endl;
	n.record_spikes(cout, n.gen_spikes(ts2));
}

void go(const string& filename){

}

int main(){
	string base_dir("../data/");
//	test_eq();
//	test_random();
//	test_bind();
//	test_neuron();
//	test_init(base_dir+"multiparent.txt");
	test_spike(base_dir + "multiparent.txt");
	return 0;
}

