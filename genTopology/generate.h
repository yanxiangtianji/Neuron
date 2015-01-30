#include <functional>
#include <random>
#include "AdjGraph.h"


AdjGraph gen_topology(const bool selfloop, const size_t n_node,
	std::function<size_t(const size_t nid)> fun_out_degree,
	std::function<bool(const size_t from, const size_t to)> fun_prob_link);

// Generate $n_edge[i]$ edges for each node $i$, randomly connect to other nodes.
AdjGraph gen_topology(const bool selfloop, const size_t n_node, const std::vector<size_t>& n_edges);

// Generate out-degree by $fun_out_degree$, randomly connect to other nodes.
AdjGraph gen_topology(const bool selfloop, const size_t n_node,
	std::function<size_t(const size_t nid)> fun_out_degree);

// Generate out-degree by $n_edge$/$fun_out_degree(i)$, randomly connect to other nodes.
AdjGraph gen_topology(const bool selfloop, const size_t n_node, const size_t n_edge,
	std::function<double(const size_t nid)> fun_out_degree);
