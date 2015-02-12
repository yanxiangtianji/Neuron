#include "Neuron.h"

using namespace std;

//tp_t Neuron::FIRE_MIN_INTERVAL=0;
const Neuron::signal_t Neuron::default_fire_sh = 0;
//Neuron::fun_delay_t Neuron::default_fun_delay = [](){return 0; };
Neuron::fun_delay_fire_t Neuron::default_fun_delay_fire = [](){return 0; };
Neuron::fun_delay_prog_t Neuron::default_fun_delay_prog = [](){return 1; };
Neuron::cb_fire_t Neuron::default_cb_fire = [](neu_ptr_t p, const tp_t& t){p->receive(t); };


Neuron::Neuron(const nid_t nid, const signal_t fire_shd, fun_delay_fire_t fire_f)
	:id(nid), fire_shreshold(fire_shd), fun_delay_fire(fire_f), last_fire_time(default_last_fire_time)
{
}

void Neuron::fire(const tp_t current){
	for(auto& p : children){
		tp_t delay = p.second();
		cb_fire(p.first, current + delay);
	}
}


void Neuron::receive(const tp_t current){
	//TODO: add other fire conditions
	if(last_fire_time + FIRE_MIN_INTERVAL < current){
		last_fire_time = current;
		fire(current + fun_delay_fire());
	}
}

bool Neuron::is_same_spike(const tp_t& early, const tp_t& later){
	return (later <= early + FIRE_MIN_INTERVAL);
}

void Neuron::clear(){
	last_fire_time = default_last_fire_time;
	fire_shreshold = default_fire_sh;
	children.clear(); 
}
