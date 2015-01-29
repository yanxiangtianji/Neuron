#pragma once
#include <iostream>

class Graph
{
public:
	Graph(const size_t n_node) :n(n_node), m(0){};
	virtual bool add(const size_t from, const size_t to)=0;
	virtual bool remove(const size_t from, const size_t to)=0;
	virtual std::ostream& output(std::ostream& os) const=0;
	//bool add(const size_t from, const size_t to){ return false; }
	//bool remove(const size_t from, const size_t to){ return false; }
	//std::ostream& output(std::ostream& os) const{ return os; }
	size_t get_n() const{ return n; }
	size_t get_m() const{ return m; }

protected:
	size_t n;//# of node
	size_t m;//# of link
};

std::ostream& operator<< (std::ostream& os, const Graph& g);
