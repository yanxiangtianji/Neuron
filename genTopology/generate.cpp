#include "generate.h"
#include <random>
#include <algorithm>
#include <iterator>
#include <string>

using namespace std;

// Generate link by using $fun_prob_link$ on each node pair.
AdjGraph gen_tp_prob(const bool selfloop, const size_t n_node,
	std::function<bool(const size_t from, const size_t to)> fun_prob_link)
{
	return AdjGraph(1);
}

void shuffle_gen_sl(AdjGraph& g, vector<size_t>& sf_vec, const size_t idx, size_t m){
	random_shuffle(sf_vec.begin(), sf_vec.end());
	for(size_t j = 0; j < m; ++j){
		g.add(idx, sf_vec[j]);
	}
}
void shuffle_gen_nsl(AdjGraph& g, vector<size_t>& sf_vec, const size_t idx, size_t m){
	random_shuffle(sf_vec.begin(), sf_vec.end());
	for(size_t j = 0; j < m; ++j){
		if(sf_vec[j] == idx){
			++m;
			continue;
		}
		g.add(idx, sf_vec[j]);
	}
}
void enum_gen_nsl(AdjGraph& g, vector<bool>& used, const size_t idx, const size_t m,
	const size_t n_node, function<size_t()> gen)
{
	used.assign(n_node, false);
	used[idx] = true;
	for(size_t j = 0; j < m; j++){
		size_t t;
		do{
			t = gen();
		} while(used[t]);
		used[t] = true;
		g.add(idx, t);
	}
}
void enum_gen_sl(AdjGraph& g, vector<bool>& used, const size_t idx, const size_t m,
	const size_t n_node, function<size_t()> gen)
{
	used.assign(n_node, false);
//	used[idx] = true;
	for(size_t j = 0; j < m; j++){
		size_t t;
		do{
			t = gen();
		} while(used[t]);
		used[t] = true;
		g.add(idx, t);
	}
}


// Generate $n_edge[i]$ edges for each node $i$, randomly connect to other nodes.
AdjGraph gen_tp_degree(const bool selfloop, const size_t n_node, const std::vector<size_t>& o_deg){
	random_device rd;
	mt19937 gen(rd());
	uniform_int_distribution<size_t> dist(0, n_node-1);
	function<size_t()> fun = [&](){return dist(gen); };
	const size_t max_od = n_node - (selfloop ? 0 : 1);	//maximum out-degree

	vector<size_t> sf_vec;	//shuffle vector. For alg_1: random shuffle a list and pick first m
	vector<bool> used;	//used vector. For alg_2: random generating unique m
	AdjGraph g(n_node);
	for(size_t i = 0; i < n_node; ++i){
		size_t m = o_deg[i];
		if(m > max_od){
			throw invalid_argument("out-degree of node("+to_string(i)+") is "+to_string(m)+" . It exceeds maximum out-degree.");
			//m = min(m, max_od);
		}
		if(n_node <= 200 || m >= (n_node << 1)) {
			//shuffle a continuous list and pick the first m
			if(sf_vec.empty()){//first use the shuffle vector
				sf_vec.reserve(n_node);
				size_t t = 0;
				generate_n(back_inserter(sf_vec), n_node, [&t](){return t++; });
//				for(size_t i = 0; i < n_node; ++i)
//					sf_vec.push_back(i);
			}
			if(selfloop)
				shuffle_gen_sl(g, sf_vec, i, m);
			else
				shuffle_gen_nsl(g, sf_vec, i, m);
		}else{
			//mark and re-generate
			if(selfloop)
				enum_gen_sl(g, used, i, m, n_node, fun);
			else
				enum_gen_nsl(g, used, i, m, n_node, fun);
		}//end if
	}
	return g;
}


// Generate out-degree by $fun_out_degree$, randomly connect to other nodes.
AdjGraph gen_tp_degree(const bool selfloop, const size_t n_node,
	std::function<size_t(const size_t nid)> fun_out_degree)
{
	vector<size_t> v;
	v.reserve(n_node);
	for (size_t i = 0; i < n_node; ++i)
		v.push_back(fun_out_degree(i));
	return gen_tp_degree(selfloop, n_node, v);
}

// Generate out-degree by $n_edge$ * ($fun_out_degree(i)/sum of all fun_out_degree(i))$, randomly connect to other nodes.
AdjGraph gen_tp_degree(const bool selfloop, const size_t n_node, const size_t n_edge,
	std::function<double(const size_t nid)> fun_out_degree)
{
	const size_t max_od = n_node - (selfloop?0:1);
	if(n_edge > max_od*n_node){
		throw invalid_argument("Total out-degree(" + to_string(n_edge) + ") exceeds maximum possible out-degree(" + to_string(max_od*n_node) + ").");
	}
	double sum = 0.0;
	vector<double> temp;
	temp.reserve(n_node);
	for (size_t i = 0; i < n_node; ++i){
		double t = max(0.0, fun_out_degree(i));
		temp.push_back(t);
		sum += t;
	}
	vector<size_t> v;
	v.reserve(n_node);
	size_t n_sum = 0;
	for(size_t i = 0; i < n_node-1; ++i){
		size_t t = static_cast<size_t>(round(n_edge * temp[i] / sum));
		t = min(t, max_od);
		v.push_back(t);
		n_sum += t;
	}
	v.push_back(n_sum >= n_edge ? 0 : n_edge - n_sum);
	return gen_tp_degree(selfloop, n_node, v);

}
