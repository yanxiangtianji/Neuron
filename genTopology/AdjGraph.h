#pragma once
#include <iostream>
#include <vector>
#include "Graph.h"

class AdjGraph:
	public Graph{
public:
	AdjGraph(const size_t n_node);
	AdjGraph(const AdjGraph& oth) = default;
	
	bool add(const size_t from, const size_t to);
	bool remove(const size_t from, const size_t to);

	void sort_up();
	std::ostream& output(std::ostream& os) const;

private:
	std::vector<std::vector<size_t> > cont;
};

