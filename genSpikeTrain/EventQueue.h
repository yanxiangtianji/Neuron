#pragma once
#include <map>
#include "Neuron.h"
#include "def.h"

class EventQueue
{
private:
	typedef std::multimap<tp_t, neu_ptr_t> cont_t;
	cont_t cont;

public:

	void push(cont_t::value_type::first_type& tp, cont_t::value_type::second_type& nid);
//	void push(cont_t::value_type& p){ push(p.first, p.second); }

	cont_t::value_type get();
	void pop();
	auto get_n_pop()->decltype(get()){ auto t = get(); pop(); return t; }

};

