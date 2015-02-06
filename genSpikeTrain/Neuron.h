#pragma once
#include <functional>
#include <vector>
#include <map>
#include <memory>
#include "def.h"

class Neuron
{
public:	//typedef
	typedef std::shared_ptr<Neuron> ptr_t;
	typedef std::function<tp_t(const tp_t)> fun_delay_t;
public:
	Neuron(const nid_t nid);
	Neuron(const nid_t nid, fun_delay_t f);
	Neuron(const Neuron&) = default;

	void add_child(ptr_t& p, const tp_t t){ children[p] = t; }
	void get_delay_fun(fun_delay_t f){ fun_delay = f; }

	void fire(const tp_t tp);
	void get(const tp_t tp);
	void reg(std::function<void(ptr_t, tp_t)> f){ cb_fire = f; }

	nid_t get_id()const { return id; }
private:
//	float delay;
	const nid_t id;
	std::map<ptr_t, tp_t> children;//child neuron and the delay to it.
	fun_delay_t fun_delay;

	std::function<void(ptr_t, tp_t)> cb_fire;
};

typedef Neuron::ptr_t neu_ptr_t;

