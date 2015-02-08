#include "Neuron.h"

tp_t Neuron::fire_min_interval=0;

Neuron::fun_delay_t Neuron::default_fun_delay = [](const tp_t& m){return m; };
Neuron::cb_fire_t Neuron::default_cb_fire = [](neu_ptr_t p, const tp_t& t){p->receive(t); };


Neuron::Neuron(const nid_t nid, const signal_t fire_shd, const tp_t fire_d, fun_delay_t fire_f, fun_delay_t prog_f)
	:id(nid), fire_shreshold(fire_shd), fire_delay(fire_d), fun_delay_f(fire_f), fun_delay_p(prog_f)
{
}

void Neuron::fire(const tp_t current){
	for(auto p : children){
		tp_t delay = fun_delay_p(p.second);
		cb_fire(p.first, current + delay);
	}
}


void Neuron::receive(const tp_t current){
	if(last_fire_time + fire_min_interval < current){
		last_fire_time = current;
		fire(current + fun_delay_f(fire_delay));
	}
}

