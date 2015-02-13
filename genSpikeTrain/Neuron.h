#pragma once
#include <functional>
#include <vector>
#include <map>
#include <memory>
#include "def.h"

class Neuron
{
public:	//for typedef
	typedef size_t nid_t;
	typedef float signal_t;
	typedef std::shared_ptr<Neuron> ptr_t;
	typedef std::function<tp_t()> fun_delay_t;
	typedef fun_delay_t fun_delay_fire_t;
	typedef fun_delay_t fun_delay_prog_t;
//	typedef std::function<void(ptr_t, const tp_t&, const signal_t&)> cb_fire_t;
	typedef std::function<void(ptr_t, const tp_t&)> cb_fire_t;
public:
//	Neuron(const nid_t nid);
	Neuron(const nid_t nid, const signal_t fire_shd = default_fire_sh, fun_delay_t fire_f = default_fun_delay_fire);
	Neuron(const Neuron&) = default;

	void add_child(ptr_t& p, const fun_delay_prog_t& t=default_fun_delay_prog){ children[p] = t; }
	void add_child(ptr_t& p, fun_delay_prog_t&& t){ children[p] = t; }

	/*!
	@brief Handle the things when this neuron fires.
	@details Call $cb_fire$ for each of its child, with proper delay.
		default $cb_fire$ calls the receive function of its each child.
	@param current The time at which it fires.
	*/
	void fire(const tp_t current);
	/*!
	@brief Register the callback function of fire.
	@param cb_f The function called, when this neuron fires.
	*/
	void reg_cb_f(std::function<void(ptr_t, tp_t)> cb_f){ cb_fire = cb_f; }
	/*!
	@brief Handle the input.
	@param current The time at which it receives a signal.
	@param amount The amount of signal the neuron actually receives.
	*/
	void receive(const tp_t current, const signal_t& amount);
	void receive(const tp_t current);

	size_t size() const{ return children.size(); }
	void clear();

//getter & setter:
	nid_t get_id()const { return id; }
	tp_t get_last_fire_time()const { return last_fire_time; }
	signal_t get_fire_shreshold()const { return fire_shreshold; }
	fun_delay_fire_t get_fun_delay_f()const{ return fun_delay_fire; }
	fun_delay_prog_t get_fun_delay_p(const ptr_t& p)const{ return children.at(p); }
	const std::map<ptr_t, fun_delay_prog_t>& get_children() const { return children; }
	void set_fire_shreshold(const signal_t& t){ fire_shreshold = t; }
	void set_fire_shreshold(signal_t&& t){ fire_shreshold = t; }
	void set_fun_delay_f(const fun_delay_fire_t& f){ fun_delay_fire = f; }
	void set_fun_delay_f(fun_delay_fire_t&& f){ fun_delay_fire = f; }
	void set_fun_delay_p(const ptr_t& p, const fun_delay_prog_t& f){ children.find(p)->second = f; }
private:
	const nid_t id;
	signal_t fire_shreshold;
	tp_t last_fire_time;
//	signal_t value;
	//delays:
	fun_delay_fire_t fun_delay_fire;
	std::map<ptr_t, fun_delay_prog_t> children;//child neuron and the propagation delay to it.

	cb_fire_t cb_fire;

/*static:*/
public:
	static bool is_same_spike(const tp_t& early, const tp_t& later);
	static tp_t get_fire_min_interval(){ return FIRE_MIN_INTERVAL; }
	static signal_t get_default_fire_sh(){ return default_fire_sh; }
//	static fun_delay_t get_default_fun_delay(){ return default_fun_delay; }
	static fun_delay_fire_t get_default_fun_delay_fire(){ return default_fun_delay_fire; }
	static fun_delay_prog_t get_default_fun_delay_prog(){ return default_fun_delay_prog; }
private:
	static const tp_t FIRE_MIN_INTERVAL=0;
	static const tp_t default_last_fire_time = 0;
	static const signal_t default_fire_sh;

//	static fun_delay_t default_fun_delay;
	static fun_delay_fire_t default_fun_delay_fire;
	static fun_delay_prog_t default_fun_delay_prog;
	static cb_fire_t default_cb_fire;
};

inline bool operator<(const Neuron& lth, const Neuron& rth){
	return lth.get_id() < rth.get_id();
}

inline bool operator==(const Neuron& lth, const Neuron& rth){
	return lth.get_id() == rth.get_id();
}


typedef Neuron::nid_t nid_t;
typedef Neuron::ptr_t neu_ptr_t;
typedef Neuron::signal_t signal_t;

