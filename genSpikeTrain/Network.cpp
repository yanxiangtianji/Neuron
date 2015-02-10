#include "Network.h"
#include "ToolRandom.h"
#include <fstream>
#include <random>
#include <algorithm>
#include <stdexcept>

using namespace std;

Network::metafun_fire_sh_t Network::default_mf_fire_sh = [](const nid_t& nid){return Neuron::get_default_fire_sh(); };
Network::metafun_fire_d_t Network::default_mf_fire_d = [](const nid_t& nid){return Neuron::get_default_fun_delay(); };
Network::metafun_prog_d_t Network::default_mf_prog_d = [](const nid_t& src, const nid_t& dst){return Neuron::get_default_fun_delay(); };;

Network::Network()
{
}


Network::~Network()
{
}

void Network::clear(){
	cont.clear();
	eq.clear();
}

void Network::gen_spikes(const std::string& o_filename, const size_t input_num){
	ofstream fout(o_filename);
	gen_spikes(fout, input_num);
	fout.close();
}

void Network::gen_spikes(const std::ostream& os, const size_t input_num){
	const tp_t MAX_TIME_INPUT = 10000;
	auto g_neu = ToolRandom::bind_gen<size_t>(uniform_int_distribution<size_t>(0, size()));
	auto g_time = ToolRandom::bind_gen<tp_t>(uniform_int_distribution<tp_t>(0, MAX_TIME_INPUT));
	input_spike_t input;
	input.reserve(input_num);
	for(size_t i = 0; i < input_num; ++i){
		input.emplace_back(g_time(), cont[g_neu()]);
	}
	sort(input.begin(), input.end());
	gen_spikes(os, input);
}

void Network::gen_spikes(const std::ostream& os, input_spike_t& input){
	
}

void Network::initial(const std::string& filename, metafun_fire_sh_t mf_fire_sh, 
	metafun_fire_d_t mf_fire, metafun_prog_d_t mf_prog)
{
	clear();
	ifstream fin(filename);
	if(!fin){
		throw runtime_error("In network::initial, input file:\"" + filename + "\" cannot be open correctly.");
		return;
	}
	size_t n, m;
	fin >> n >> m;
	function<void(neu_ptr_t, tp_t)> cb = 
		bind(static_cast<void (eq_t::*)(const tp_t&,const neu_ptr_t&)>(&eq_t::push), &eq, placeholders::_2, placeholders::_1);
	for(size_t i = 0; i < n; ++i){
		auto p = make_shared<Neuron>(i, mf_fire_sh(i), mf_fire(i));
		p->reg_cb_f(cb);
		cont.push_back(p);
	}
//	function<tp_t()> prog_mean_meta_fun = ToolRandom::bind_gen_bmin(0, normal_distribution<double>(10, 2));
	for(size_t i = 0; i < n; ++i){
		size_t src, pn;
		fin >> src >> pn;
		neu_ptr_t& ptr = cont[src];
		for(size_t j = 0; j < pn; ++j){
			size_t dst;
			fin >> dst;
			//auto fp = ToolRandom::bind_gen_bmin(0, normal_distribution<double>(prog_mean_meta_fun(), 1));
			ptr->add_child(cont[dst],mf_prog(src,dst));
		}
	}
}

