#include "Network.h"
#include "ToolRandom.h"
#include <fstream>
#include <random>
#include <algorithm>
#include <stdexcept>

using namespace std;

Network::metafun_fire_sh_t Network::default_mf_fire_sh = [](const nid_t& nid){return Neuron::get_default_fire_sh(); };
Network::metafun_fire_d_t Network::default_mf_fire_d = [](const nid_t& nid){
	return Neuron::get_default_fun_delay_fire(); };
Network::metafun_prog_d_t Network::default_mf_prog_d = [](const nid_t& src, const nid_t& dst){
	return Neuron::get_default_fun_delay_prog(); };;

Network::Network()
{
}


Network::~Network()
{
}

void Network::clear(){
	cont.clear();
	input_layer.clear();
	eq.clear();
}

void Network::initial(const std::string& filename, metafun_fire_sh_t mf_fire_sh,
	metafun_fire_d_t mf_fire, metafun_prog_d_t mf_prog)
{
	ifstream fin(filename);
	if(!fin){
		throw runtime_error("In network::initial, input file:\"" + filename + "\" cannot be open correctly.");
		return;
	}
	initial(fin, mf_fire_sh, mf_fire, mf_prog);
}

void Network::initial(std::istream& is, metafun_fire_sh_t mf_fire_sh,
	metafun_fire_d_t mf_fire, metafun_prog_d_t mf_prog)
{
	clear();
	size_t n, m;
	is >> n >> m;
	for(size_t i = 0; i < n; ++i){
		auto p = make_shared<Neuron>(i, mf_fire_sh(i), mf_fire(i));
		add_node(p);
	}
	//	function<tp_t()> prog_mean_meta_fun = ToolRandom::bind_gen_bmin(0, normal_distribution<double>(10, 2));
	for(size_t i = 0; i < n; ++i){
		size_t chl, pn;
		is >> chl >> pn;
		if(pn == 0)
			input_layer.push_back(chl);
		neu_ptr_t& ptr = cont[chl];
		for(size_t j = 0; j < pn; ++j){
			size_t par;
			is >> par;
			//auto fp = ToolRandom::bind_gen_bmin(0, normal_distribution<double>(prog_mean_meta_fun(), 1));
			cont[par]->add_child(ptr, mf_prog(chl, par));
		}
	}
}

void Network::_init_input_layer(){
	for(size_t i = 0; i < cont.size();++i){
		if(cont[i]->size() == 0)
			input_layer.push_back(i);
	}
	input_layer.shrink_to_fit();
}

void Network::add_node(const neu_ptr_t& p){
	size_t s = cont.size();
	cont.push_back(p);
	idx_mapping[p] = s;
}

void Network::record_spikes(std::ostream& os, const spike_trains_t& input){
	for(size_t i = 0; i < input.size(); ++i){
		neu_ptr_t p = cont[i];
		os << p->get_id() << '\n';
		for(const auto& t : input[i])
			os << ' ' << t;
		os << '\n';
	}
}

Network::spike_trains_t Network::gen_spikes(const size_t input_num, const bool only_input_layer, const tp_t MAX_TIME_INPUT){
	function<size_t()> g_neu;
	if(only_input_layer){
		if(input_layer.size() == 0){
			throw runtime_error("Generating spikes starting on input layer ,but there is no input layer neuron.");
		}
		g_neu=[&](){
			static auto gen = ToolRandom::bind_gen<size_t>(uniform_int_distribution<size_t>(0, input_layer.size() - 1));
			return input_layer[gen()];
		};
	}else{
		g_neu=ToolRandom::bind_gen<size_t>(uniform_int_distribution<size_t>(0, size() - 1));
	}
	function<tp_t()> g_time = ToolRandom::bind_gen<tp_t>(uniform_int_distribution<tp_t>(1, MAX_TIME_INPUT));
	spike_trains_t input(size());
	for(size_t i = 0; i < input_num; ++i){
		input[g_neu()].push_back(g_time());
	}
	for(auto& train:input)
		sort(train.begin(), train.end());
	return gen_spikes(input);
}

Network::spike_trains_t Network::gen_spikes(spike_trains_t& input){
	//initial neuron callback
	function<void(neu_ptr_t, tp_t)> cb =
//		bind(static_cast<void (eq_t::*)(const tp_t&, const neu_ptr_t&)>(&eq_t::push), &eq, placeholders::_2, placeholders::_1);
		bind(&eq_t::push, &eq, placeholders::_2, placeholders::_1);
	for(auto& pneu : cont)
		pneu->reg_cb_f(cb);

	//push the initial spikes
	for(size_t i = 0; i < size();++i){
		neu_ptr_t p = cont[i];
		for(const tp_t& t : input[i])
			eq.push(t, p);
	}
	//go
	spike_trains_t res(size());
	while(!eq.empty()){
		pair<const tp_t,neu_ptr_t> evt = eq.get_n_pop();
		const tp_t t = evt.first;
		neu_ptr_t& p = evt.second;
		res[idx_mapping[p]].push_back(t);
		p->receive(t);
	}
	for(auto& train : res){
		sort(train.begin(), train.end());
		auto it=unique(train.begin(), train.end(), Neuron::is_same_spike);
		train.erase(it, train.end());
	}
	return res;
}

void Network::output_structure(std::ostream& os){
	os << size() << '\n';
	for(size_t i = 0; i < size(); ++i){
		neu_ptr_t p = cont[i];
		os << p->get_id() << ' ' << p->size() << '\n';
		for(const auto&par : p->get_children()){
			os << ' ' << par.first->get_id();
		}
		os << '\n';
	}
}

