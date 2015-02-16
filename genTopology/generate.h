#include <functional>
#include "AdjGraph.h"

// Generate link by using $fun_prob_link$ on each node pair.
AdjGraph gen_tp_prob(const bool selfloop, const size_t n_node,
	std::function<bool(const size_t from, const size_t to)> fun_prob_link);

//TODO: add functions depend on in-degree

// Generate $n_edge[i]$ edges for each node $i$, randomly connect to other nodes.
AdjGraph gen_tp_degree(const bool selfloop, const size_t n_node, const std::vector<size_t>& o_deg);

// Generate out-degree by $fun_out_degree$, randomly connect to other nodes.
AdjGraph gen_tp_degree(const bool selfloop, const size_t n_node,
	std::function<size_t(const size_t nid)> fun_out_degree);

// Generate out-degree by $n_edge$ * (fun_out_degree(i)/sum of all fun_out_degree(i))$, randomly connect to other nodes.
/*!
 negative output of $fun_out_degree$ is regarded as 0
*/
AdjGraph gen_tp_degree(const bool selfloop, const size_t n_node, const size_t n_edge,
	std::function<double(const size_t nid)> fun_out_degree);
