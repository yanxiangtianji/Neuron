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
	typedef std::vector<std::pair<tp_t, neu_ptr_t> > input_spike_t;
	typedef EventQueue<tp_t, neu_ptr_t> eq_t;
	typedef std::function<Neuron::signal_t(const nid_t&)> metafun_fire_sh_t;
	typedef std::function<Neuron::fun_delay_fire_t(const nid_t&)> metafun_fire_d_t;
	typedef std::function<Neuron::fun_delay_prog_t(const nid_t&, const nid_t&)> metafun_prog_d_t;
public:
	Network();
	~Network();

//	void initial(const std::string& filename);
	void initial(const std::string& filename, metafun_fire_sh_t mf_fire_sh = default_mf_fire_sh,
		metafun_fire_d_t mf_fire = default_mf_fire_d, metafun_prog_d_t mf_prog = default_mf_prog_d);

	void gen_spikes(const std::ostream& os, input_spike_t& input);
	void gen_spikes(const std::ostream& os, const size_t input_num);
	void gen_spikes(const std::string& o_filename, const size_t input_num);

	size_t size() const{ return cont.size(); }
	bool empty() const { return cont.empty(); }
	void clear();
//getter & setter:
	neu_ptr_t get(const nid_t& id){ return cont[id]; }
private:
//node:
	std::vector<neu_ptr_t> cont;
//event:
	eq_t eq;

private:
	static metafun_fire_sh_t default_mf_fire_sh;
	static metafun_fire_d_t default_mf_fire_d;
	static metafun_prog_d_t default_mf_prog_d;

};

