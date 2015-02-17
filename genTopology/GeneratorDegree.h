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

	/*!
	@brief Generate with given degree
	@details For allow-loop case: exactly follows the order in degree.
		For not-allow-loop case: only follows the content of degree, regardless its order.
	@param degree Degree list.
	@return The generated graph
	@exception Throws invalid_argument when degree cannot be used to generated a required graph.
	*/
	AdjGraph gen(const std::vector<size_t>& degree);
	//allow-loop version. 
	AdjGraph gen_aloop(const std::vector<size_t>& degree);
	//no-loop version. Do not follow order of degree exactly. Just follow its content.
	AdjGraph gen_nloop(const std::vector<size_t>& degree);

	// Generate degree by $fun_degree$, randomly connect to other nodes.
	AdjGraph gen(std::function<size_t(const size_t nid)> fun_degree, const bool modify_if_necessary);
	AdjGraph gen(std::function<size_t()> fun_degree, const bool modify_if_necessary);
	/*!
	Generate degree by $n_edge$ * (fun_por_degree(i)/sum of all fun_por_degree(i))$, randomly connect to other nodes.
	negative output of $fun_out_degree$ is regarded as 0
	*/
	AdjGraph gen(const size_t n_edge, std::function<double(const size_t nid)> fun_por_degree, const bool modify_if_necessary);
	AdjGraph gen(const size_t n_edge, std::function<double()> fun_por_degree, const bool modify_if_necessary);

private:
	AdjGraph forward_from_distribution(std::vector<size_t>&& degree, const bool modify_if_necessary);
	std::vector<size_t> _make_degree_from_portion(const size_t n_edge,
		const std::vector<double>& portion, const double sum);

	//no self-loop (basic generating method, may lead to indirect loops)
	//generating algorithm 1: shuffle a list [0, n_node-1] and pick the first m
	void shuffle_gen_nsl(std::vector<size_t>& sf_vec, const size_t idx, const size_t m, add_fun_bind_t add);
	//generating algorithm 2: keep random generating until get m non-repeated number
	void enum_gen_nsl(std::vector<bool>& used, const size_t idx, const size_t m, add_fun_bind_t add);
	//no any loop
	void shuffle_gen_nl(std::vector<size_t>& sf_vec, const size_t idx, const size_t m, add_fun_bind_t add);
	void enum_gen_nl(std::vector<bool>& used, const size_t idx, const size_t m, add_fun_bind_t add);
	void _init_sf_vec_al(std::vector<size_t>& sf_vec);
	void _init_sf_vec_nl(std::vector<size_t>& sf_vec);
	//check whether the shuffle method might perform better
	bool _is_shuffle_better(const size_t m) const;

	add_fun_t get_add_fun(AdjGraph& g);
//	void set_fun_shuffle_gen();
//	void set_fun_enum_gen();

	bool check_degree(const std::vector<size_t>& degree);
	//check whether the degree can be used to construct a directed, no self-loop graph
	bool _check_degree_construct(const std::vector<size_t>& degree);
	//check whether the degree can be used to construct a DAG (directed acyclic graph)
	bool _check_degree_dag(const std::vector<size_t>& degree);

	std::vector<size_t> sort_degree_for_dag(const std::vector<size_t>& degree);
	std::vector<size_t> modify_degree_for_dag(std::vector<size_t>& degree);

private:
	size_t n_node;
	DegreeType type;
	bool allow_loop;
	size_t SHUFFLE_THRESHOLD;

	std::mt19937 _random_gen;
	std::function<size_t()> node_random_gen;
//	std::function<void(std::vector<size_t>&, const size_t, const size_t, add_fun_bind_t& add)> shuffle_gen;
//	std::function<void(std::vector<bool>&, const size_t, const size_t, add_fun_bind_t& add)> enum_gen;
};

inline bool GeneratorDegree::_is_shuffle_better(const size_t m) const{
	return n_node <= SHUFFLE_THRESHOLD || m >= (n_node >> 1);
}

