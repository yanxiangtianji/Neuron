#pragma once
#include <functional>
#include <random>
#include "AdjGraph.h"
//#include 

class GeneratorDegree
{
public:
	enum class DegreeType{ INDEGREE, OUTDEGREE };
public:
	GeneratorDegree(const size_t num_node, const DegreeType type, 
		const bool self_loop, const bool indirect_loop, const size_t shuffle_threshold=200);

	// Generate with given degree
	AdjGraph gen(const std::vector<size_t>& degree);
	// Generate degree by $fun_degree$, randomly connect to other nodes.
	AdjGraph gen(std::function<size_t(const size_t nid)> fun_degree);
	/*!
	Generate degree by $n_edge$ * (fun_por_degree(i)/sum of all fun_por_degree(i))$, randomly connect to other nodes.
	negative output of $fun_out_degree$ is regarded as 0
	*/
	AdjGraph gen(const size_t n_edge, std::function<double(const size_t nid)> fun_por_degree);

private:
	void shuffle_gen_sl(AdjGraph& g, std::vector<size_t>& sf_vec, const size_t idx, const size_t m);
	void shuffle_gen_nsl(AdjGraph& g, std::vector<size_t>& sf_vec, const size_t idx, const size_t m);
	void enum_gen_nsl(AdjGraph& g, std::vector<bool>& used, const size_t idx, const size_t m);
	void enum_gen_sl(AdjGraph& g, std::vector<bool>& used, const size_t idx, const size_t m);
	void _enum_gen_core(AdjGraph& g, std::vector<bool>& used, const size_t idx, const size_t m);
	bool _is_shuffle_better(const size_t m) const;

	std::function<bool(const size_t, const size_t)> get_add_fun(AdjGraph& g);
	void set_fun_shuffle_gen();
	void set_fun_enum_gen();

private:
	size_t n_node;
	DegreeType type;
	bool self_loop;
	bool indirect_loop;
	size_t SHUFFLE_THRESHOLD;

	std::mt19937 _random_gen;
	std::function<size_t()> node_random_gen;
	std::function<void(AdjGraph&, std::vector<size_t>&, const size_t, const size_t)> shuffle_gen;
	std::function<void(AdjGraph&, std::vector<bool>&, const size_t, const size_t)> enum_gen;
};


bool GeneratorDegree::_is_shuffle_better(const size_t m) const{
	return n_node <= SHUFFLE_THRESHOLD || m >= (n_node << 1);
}
