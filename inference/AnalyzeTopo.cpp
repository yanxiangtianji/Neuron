#include "AnalyzeTopo.h"

using namespace std;

AnalyzeTopo::AnalyzeTopo(const size_t n)
	:n_node(n), count(n, adj_g_t::value_type(n))
{
}


AnalyzeTopo::~AnalyzeTopo()
{
}


void AnalyzeTopo::add(const adj_g_t& g){
	for(size_t i = 0; i < n_node;++i){
		for(size_t j : g[i])
			++count[i][j];
	}
}

AnalyzeTopo::prob_g_t AnalyzeTopo::get_prob_g() const{
	prob_g_t res(n_node,prob_g_t::value_type(n_node));
	double n = n_graph;
	for(size_t i = 0; i < n_node; ++i){
		for(size_t j = 0; j < n_node; ++j){
			res[i][j] = count[i][j] / n;
		}
	}
	return res;
}

