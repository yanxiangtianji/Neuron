#include "GeneratorDegree.h"
#include <random>
#include <string>
#include <algorithm>
#include <stdexcept>
#include <chrono>

using namespace std;

GeneratorDegree::GeneratorDegree(const size_t num_node, const DegreeType type, 
	const bool self_loop, const bool indirect_loop, const size_t shuffle_threshold)
	:n_node(num_node), type(type), self_loop(self_loop), indirect_loop(indirect_loop), SHUFFLE_THRESHOLD(shuffle_threshold)
{
	auto seed = chrono::system_clock::now().time_since_epoch().count();
	_random_gen.seed(static_cast<unsigned long>(seed));
	node_random_gen = bind(uniform_int_distribution<size_t>(0,n_node-1),_random_gen);
}

std::function<bool(const size_t, const size_t)> GeneratorDegree::get_add_fun(AdjGraph& g){
	using placeholders::_1;
	using placeholders::_2;
	if(type == DegreeType::INDEGREE)
		return bind(&AdjGraph::add_parent, g, _1, _2);
	else
		return bind(&AdjGraph::add_child, g, _1, _2);
}
void GeneratorDegree::set_fun_shuffle_gen(){
	using namespace placeholders;
	if(self_loop == true)
		shuffle_gen = bind(&GeneratorDegree::shuffle_gen_sl, this, _1, _2, _3, _4);
	else
		shuffle_gen = bind(&GeneratorDegree::shuffle_gen_nsl, this, _1, _2, _3, _4);
}
void GeneratorDegree::set_fun_enum_gen(){
	using namespace placeholders;
	if(self_loop == true)
		enum_gen = bind(&GeneratorDegree::enum_gen_sl, this, _1, _2, _3, _4);
	else
		enum_gen = bind(&GeneratorDegree::enum_gen_nsl, this, _1, _2, _3, _4);
}


void GeneratorDegree::shuffle_gen_sl(AdjGraph& g, vector<size_t>& sf_vec, const size_t idx, const size_t m){
	random_shuffle(sf_vec.begin(), sf_vec.end());
	for(size_t j = 0; j < m; ++j){
		g.add(idx, sf_vec[j]);
	}
}
void GeneratorDegree::shuffle_gen_nsl(AdjGraph& g, vector<size_t>& sf_vec, const size_t idx, const size_t m){
	random_shuffle(sf_vec.begin(), sf_vec.end());
	size_t pick_n = m;
	for(size_t j = 0; j < pick_n; ++j){
		if(sf_vec[j] == idx){
			++pick_n;
			continue;
		}
		g.add(idx, sf_vec[j]);
	}
}

void GeneratorDegree::_enum_gen_core(AdjGraph& g, vector<bool>& used, const size_t idx, const size_t m){
	for(size_t j = 0; j < m; j++){
		size_t t;
		do{
			t = node_random_gen();
		} while(used[t]);
		used[t] = true;
		g.add(idx, t);
	}
}

void GeneratorDegree::enum_gen_nsl(AdjGraph& g, vector<bool>& used, const size_t idx, const size_t m)
{
	used.assign(n_node, false);
	used[idx] = true;
	_enum_gen_core(g, used, idx, m);
}
void GeneratorDegree::enum_gen_sl(AdjGraph& g, vector<bool>& used, const size_t idx, const size_t m)
{
	used.assign(n_node, false);
//	used[idx] = true;
	_enum_gen_core(g, used, idx, m);
}


// Generate $n_edge[i]$ edges for each node $i$, randomly connect to other nodes.
AdjGraph GeneratorDegree::gen(const std::vector<size_t>& deg){
	random_device rd;
	mt19937 gen(rd());
	uniform_int_distribution<size_t> dist(0, n_node - 1);
	function<size_t()> fun = [&](){return dist(gen); };
	const size_t max_od = n_node - (self_loop ? 0 : 1);	//maximum out-degree

	vector<size_t> sf_vec;	//shuffle vector. For alg_1: random shuffle a list and pick first m
	vector<bool> used;	//used vector. For alg_2: random generating unique m
	AdjGraph g(n_node);
	for(size_t i = 0; i < n_node; ++i){
		size_t m = deg[i];
		if(m > max_od){
			throw invalid_argument("out-degree of node(" + to_string(i) + ") is " + to_string(m) + " . It exceeds maximum out-degree.");
			//m = min(m, max_od);
		}
		if(n_node <= 200 || m >= (n_node << 1)) {
			//shuffle a continuous list and pick the first m
			if(sf_vec.empty()){//first use the shuffle vector
				sf_vec.reserve(n_node);
				size_t t = 0;
				generate_n(back_inserter(sf_vec), n_node, [&t](){return t++; });
			}
			//if(self_loop)
			//	shuffle_gen_sl(g, sf_vec, i, m);
			//else
			//	shuffle_gen_nsl(g, sf_vec, i, m);
			shuffle_gen(g, sf_vec, i, m);
		} else{
			//mark and re-generate
			//if(self_loop)
			//	enum_gen_sl(g, used, i, m);
			//else
			//	enum_gen_nsl(g, used, i, m);
			enum_gen(g, used, i, m);
		}//end if
	}
	return g;
}


// Generate out-degree by $fun_out_degree$, randomly connect to other nodes.
AdjGraph GeneratorDegree::gen(std::function<size_t(const size_t nid)> fun_degree)
{
	vector<size_t> v;
	v.reserve(n_node);
	for(size_t i = 0; i < n_node; ++i)
		v.push_back(fun_degree(i));
	return gen(v);
}

// Generate out-degree by $n_edge$ * (fun_por_degree(i)/sum of all fun_por_degree(i))$, randomly connect to other nodes.
AdjGraph GeneratorDegree::gen(const size_t n_edge, std::function<double(const size_t nid)> fun_por_degree)
{
	const size_t max_od = n_node - (self_loop ? 0 : 1);
	if(n_edge > max_od*n_node){
		throw invalid_argument("Total out-degree(" + to_string(n_edge) +
			") exceeds maximum possible out-degree(" + to_string(max_od*n_node) + ").");
	}
	double sum = 0.0;
	vector<double> temp;
	temp.reserve(n_node);
	for(size_t i = 0; i < n_node; ++i){
		double t = max(0.0, fun_por_degree(i));
		temp.push_back(t);
		sum += t;
	}
	vector<size_t> v;
	v.reserve(n_node);
	size_t n_sum = 0;
	for(size_t i = 0; i < n_node - 1; ++i){
		size_t t = static_cast<size_t>(round(n_edge * temp[i] / sum));
		t = min(t, max_od);
		v.push_back(t);
		n_sum += t;
	}
	v.push_back(n_sum >= n_edge ? 0 : n_edge - n_sum);
	return gen(v);
}

