#pragma once
#include <functional>
#include <random>
#include "AdjGraph.h"
//#include 

class GeneratorDegree
{
public:
	enum class DegreeType{ INDEGREE, OUTDEGREE };
private:
	typedef std::function<bool(const size_t, const size_t)> add_fun_t;
	typedef std::function<bool(const size_t)> add_fun_bind_t;
public:
	GeneratorDegree(const size_t num_node, const DegreeType type, 
		const bool allow_loop, const size_t shuffle_threshold=200);

	// Generate with given degree
	AdjGraph gen(const std::vector<size_t>& degree);
	/*!
	no-loop version. 
	Do not follow order of degree exactly. Just follow its content.
	*/
	AdjGraph gen_nl(const std::vector<size_t>& degree);

	// Generate degree by $fun_degree$, randomly connect to other nodes.
	AdjGraph gen(std::function<size_t(const size_t nid)> fun_degree);
	/*!
	Generate degree by $n_edge$ * (fun_por_degree(i)/sum of all fun_por_degree(i))$, randomly connect to other nodes.
	negative output of $fun_out_degree$ is regarded as 0
	*/
	AdjGraph gen(const size_t n_edge, std::function<double(const size_t nid)> fun_por_degree);

private:
	//no self-loop (basic generating method, may lead to indirect loops)
	//generating algorithm 1: shuffle a list [0, n_node-1] and pick the first m
	void shuffle_gen_nsl(std::vector<size_t>& sf_vec, const size_t idx, const size_t m, add_fun_bind_t add);
	//generating algorithm 2: keep random generating until get m non-repeated number
	void enum_gen_nsl(std::vector<bool>& used, const size_t idx, const size_t m, add_fun_bind_t add);
	//no any loop
	void shuffle_gen_nl(std::vector<size_t>& sf_vec, const size_t idx, const size_t m, add_fun_bind_t add);
	void enum_gen_nl(std::vector<bool>& used, const size_t idx, const size_t m, add_fun_bind_t add);
	//check whether the shuffle method might perform better
	bool _is_shuffle_better(const size_t m) const;

	add_fun_t get_add_fun(AdjGraph& g);
	void set_fun_shuffle_gen();
	void set_fun_enum_gen();

	bool check_degree(const std::vector<size_t>& degree);
	//check whether the degree can be used to construct a directed, no self-loop graph
	bool _check_degree_construct(const std::vector<size_t>& degree);
	//check whether the degree can be used to construct a DAG (directed acyclic graph)
	bool _check_degree_dag(const std::vector<size_t>& degree);

	std::vector<size_t> prepare_degree_for_dag(const std::vector<size_t>& degree);

private:
	size_t n_node;
	DegreeType type;
	bool allow_loop;
	size_t SHUFFLE_THRESHOLD;

	bool start_from_distribution=false;

	std::mt19937 _random_gen;
	std::function<size_t()> node_random_gen;
	std::function<void(std::vector<size_t>&, const size_t, const size_t, add_fun_bind_t& add)> shuffle_gen;
	std::function<void(std::vector<bool>&, const size_t, const size_t, add_fun_bind_t& add)> enum_gen;
};


inline bool GeneratorDegree::_is_shuffle_better(const size_t m) const{
	return n_node <= SHUFFLE_THRESHOLD || m >= (n_node >> 1);
}
