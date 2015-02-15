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

	bool add_parent(const size_t chd, const size_t pnt){ return add(pnt, chd); }
	bool add_child(const size_t pnt, const size_t chd){ return add(pnt, chd); }
	bool remove_parent(const size_t chd, const size_t pnt){ return remove(pnt, chd); }
	bool remove_child(const size_t pnt, const size_t chd){ return remove(pnt, chd); }

	AdjGraph& sort_up();
	std::ostream& output(std::ostream& os) const;

private:
	//store each node's children
	std::vector<std::vector<size_t> > cont;
	bool unsorted_any;
	std::vector<bool> unsorted;
};

