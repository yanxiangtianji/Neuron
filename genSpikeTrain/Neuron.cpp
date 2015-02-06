#include "Neuron.h"


Neuron::Neuron(const nid_t nid, fun_delay_t f) :id(nid), fun_delay(f)
{
}

void Neuron::fire(const tp_t tp){
	for(auto p : children){
		tp_t t = fun_delay(p.second);
		cb_fire(p.first, t);
	}
}


void Neuron::get(const tp_t tp){
	fire(tp);
}

