#include "generate.h"

using namespace std;

AdjGraph gen_topology(const size_t n_node, std::function<size_t(const size_t nid)> outdegree_n_fun,
	std::function<bool(const size_t from, const size_t to)> link_pred_fun)
{
	return AdjGraph(1);
}

// Generate $n_edge[i]$ edges for each node $i$, randomly connect to other nodes.
AdjGraph gen_topology(const bool selfloop, const size_t n_node, const std::vector<size_t>& n_edges){

}


// Generate out-degree by $fun_out_degree$, randomly connect to other nodes.
AdjGraph gen_topology(const bool selfloop, const size_t n_node,
	std::function<size_t(const size_t nid)> fun_out_degree)
{
	vector<size_t> v;
	v.reserve(n_node);
	for (size_t i = 0; i < n_node; ++i)
		v.push_back(fun_out_degree(i));
	return gen_topology(selfloop, n_node, v);
}

// Generate out-degree by $n_edge$/$fun_out_degree(i)$, randomly connect to other nodes.
AdjGraph gen_topology(const bool selfloop, const size_t n_node, const size_t n_edge,
	std::function<double(const size_t nid)> fun_out_degree)
{
	double sum = 0.0;
	vector<double> temp;
	temp.reserve(n_node);
	for (size_t i = 0; i < n_node; ++i){
		double t = fun_out_degree(i);
		temp.push_back(t);
		sum += t;
	}
	vector<size_t> v;
	v.reserve(n_node);
	size_t n_sum = 0;
	for(size_t i = 0; i < n_node-1; ++i){
		size_t t = round(n_edge / temp[i]);
		v.push_back(t);
		n_sum += t;
	}
	v.push_back(n_edge - n_sum);
	return gen_topology(selfloop, n_node, v);

}
