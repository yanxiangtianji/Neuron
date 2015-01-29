#include "Graph.h"


bool Graph::add(const size_t from, const size_t to){
	return false;
}

bool Graph::remove(const size_t from, const size_t to){
	return false;
}

std::ostream& Graph::output(std::ostream& os) const{
	return os;
}

std::ostream& operator<< (std::ostream& os, const Graph& g){
	return g.output(os);
}
