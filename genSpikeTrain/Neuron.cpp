#include "Neuron.h"
#include <limits>

using namespace std;

tp_t Neuron::fire_min_interval=0;
const Neuron::signal_t Neuron::default_fire_sh = 0;
Neuron::fun_delay_t Neuron::default_fun_delay = [](){return 0; };
Neuron::cb_fire_t Neuron::default_cb_fire = [](neu_ptr_t p, const tp_t& t){p->receive(t); };


Neuron::Neuron(const nid_t nid, const signal_t fire_shd, fun_delay_fire_t fire_f)
	:id(nid), fire_shreshold(fire_shd), fun_delay_fire(fire_f), last_fire_time(numeric_limits<tp_t>::min())
{
}

void Neuron::fire(const tp_t current){
	for(auto p : children){
		tp_t delay = p.second();
		cb_fire(p.first, current + delay);
	}
}


void Neuron::receive(const tp_t current){
	//TODO: add other fire conditions
	if(last_fire_time + fire_min_interval > current){
		last_fire_time = current;
		fire(current + fun_delay_fire());
	}
}

