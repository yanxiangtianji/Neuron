#include "Network.h"
#include "ToolRandom.h"
#include <fstream>
#include <random>

using namespace std;

Network::Network()
{
}


Network::~Network()
{
}

void Network::initial(const std::string& filename, Neuron::fun_delay_t& fun){
	ifstream fin(filename);
	size_t n, m;
	fin >> n >> m;
	random_device rd;
	//Neuron::fun_delay_t fun = [&](const tp_t mean){return static_cast<tp_t>(normal_distribution<>(mean, 5)(rd)); };
	//Neuron::fun_delay_t fun = [](const tp_t mean){return mean; };
	for(size_t i = 0; i < n; ++i){
		cont.push_back(make_shared<Neuron>(i));
	}
	//double mean = RandomTool::get_double(5, 15), stddev = RandomTool::get_double(0.1, 2);
	double mean = 10, stddev = 2;
	function<tp_t()> prog_mean_meta_fun = ToolRandom::bind_gen_bmin(0, normal_distribution<double>(mean, stddev));
	for(size_t i = 0; i < n; ++i){
		size_t id, pn;
		fin >> id >> pn;
		neu_ptr_t& ptr = cont[id];
		for(size_t j = 0; j < pn; ++j){
			size_t t;
			fin >> t;
			tp_t pm = prog_mean_meta_fun();
			ptr->add_child(cont[t],ToolRandom::bind_gen_bmin(0,normal_distribution<double>(pm,1)));
		}
	}
}

