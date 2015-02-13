#pragma once
#include <string>
#include <vector>
#include <ostream>
#include <utility>
#include "EventQueue.h"
#include "Neuron.h"
#include "def.h"

class Network
{
public:
	typedef std::vector<tp_t> spike_train_t;
	typedef std::vector<spike_train_t> spike_trains_t;
	typedef EventQueue<tp_t, neu_ptr_t> eq_t;
	//TODO: change "const nid_t&" to "neu_ptr_t"
	typedef std::function<Neuron::signal_t(const nid_t&)> metafun_fire_sh_t;
	typedef std::function<Neuron::fun_delay_fire_t(const nid_t&)> metafun_fire_d_t;
	typedef std::function<Neuron::fun_delay_prog_t(const nid_t&, const nid_t&)> metafun_prog_d_t;
public:
	Network();
	~Network();

	void initial(std::istream& is, metafun_fire_sh_t mf_fire_sh = default_mf_fire_sh,
		metafun_fire_d_t mf_fire = default_mf_fire_d, metafun_prog_d_t mf_prog = default_mf_prog_d);
	void initial(const std::string& filename, metafun_fire_sh_t mf_fire_sh = default_mf_fire_sh,
		metafun_fire_d_t mf_fire = default_mf_fire_d, metafun_prog_d_t mf_prog = default_mf_prog_d);

	spike_trains_t gen_spikes(const size_t input_num, const bool only_input_layer=true, const tp_t MAX_TIME_INPUT = 10000);
	spike_trains_t gen_spikes(spike_trains_t& input);
	void output_spikes(std::ostream& os, const spike_trains_t& input);

	void add_node(const neu_ptr_t& p);
	void output_structure(std::ostream& os);

	size_t size() const{ return cont.size(); }
	bool empty() const { return cont.empty(); }
	void clear();

//getter & setter:
	neu_ptr_t get(const nid_t& id){ return cont[id]; }
private:
	void _init_input_layer();
private:
//node:
	//all nodes:
	std::vector<neu_ptr_t> cont;
	//the idxes (in $cont$) of nodes without parent
	std::vector<size_t> input_layer;
	std::map<neu_ptr_t, size_t> idx_mapping;
//event:
	eq_t eq;

/*static:*/

private:
	static metafun_fire_sh_t default_mf_fire_sh;
	static metafun_fire_d_t default_mf_fire_d;
	static metafun_prog_d_t default_mf_prog_d;
public:
	static const metafun_fire_sh_t get_default_mf_fire_sh(){ return default_mf_fire_sh; }
	static const metafun_fire_d_t get_default_mf_fire_d(){ return default_mf_fire_d; }
	static const metafun_prog_d_t get_default_mf_prog_d(){ return default_mf_prog_d; }

};

