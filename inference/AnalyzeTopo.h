#pragma once
#include <vector>
#include "AlgBase.h"

class AnalyzeTopo
{
public:
	typedef AlgBase::pss_t adj_g_t;
	typedef std::vector<std::vector<double>> prob_g_t;

public:
	AnalyzeTopo(const size_t n);
	~AnalyzeTopo();

	void add(const adj_g_t& g);
	prob_g_t get_prob_g() const;
	adj_g_t get_adj_g() const{ return count; }
	size_t get_n_node()const{ return n_node; }
	size_t get_n_graph()const{ return n_graph; }


private:
	size_t n_node;
	size_t n_graph=0;
	adj_g_t count;
};

