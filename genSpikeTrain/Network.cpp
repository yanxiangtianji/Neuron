#include "Network.h"
#include <fstream>
#include <random>

using namespace std;

Network::Network()
{
}


Network::~Network()
{
}

double test(){
	random_device rd;
	return normal_distribution<>(4, 5)(rd);
}

void Network::initial(const std::string& filename, Neuron::fun_delay_t& gen){
	ifstream fin(filename);
	size_t n, m;
	fin >> n >> m;
	random_device rd;
	auto fun = [&](const tp_t mean){return static_cast<tp_t>(normal_distribution<>(mean, 5)(rd)); };
	//auto fun = [](const tp_t mean){return mean; };
	normal_distribution<> n_dis(4, 2);
	for(size_t i = 0; i < n; ++i){
		cont.push_back(make_shared<Neuron>(i, fun));
	}
	for(size_t i = 0; i < n; ++i){
		size_t p, pn;
		fin >> p >> pn;
		neu_ptr_t& ptr = cont[p];
		for(size_t j = 0; j < pn; ++j){
			size_t t;
			fin >> t;
			ptr->add_child(cont[t],rd());
		}
	}
}

