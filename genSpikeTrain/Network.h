#pragma once
#include <functional>
#include <string>
#include <vector>
#include "EventQueue.h"
#include "Neuron.h"

class Network
{
public:
	Network();
	~Network();

	void initial(const std::string& filename,Neuron::fun_delay_t& gen);
private:
//node:
	std::vector<neu_ptr_t> cont;
//event:
	EventQueue<tp_t, neu_ptr_t> eq;
};

