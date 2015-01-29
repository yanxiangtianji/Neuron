#pragma once
#include "Graph.h"
#include <vector>
#include <set>

class AdjGraphSec :
	public Graph
{
public:
	AdjGraphSec(const size_t n_node);
	AdjGraphSec(const AdjGraphSec& oth) = default;

	bool add(const size_t from, const size_t to);
	bool remove(const size_t from, const size_t to);

	void sort_up();
	std::ostream& output(std::ostream& os) const;

private:
	std::vector<std::set<size_t> > cont;
};

