#pragma once
#include <istream>
#include <string>
#include <vector>
#include <tuple>

class CompareTopo
{
	typedef std::vector<std::vector<size_t> > vvs_t;
	typedef std::tuple<std::vector<size_t>, vvs_t, vvs_t> cmp_res_t;
public:
	CompareTopo(const std::string& fn);

	//return difference of each neuron's parent (# of matched, new in fn, lost in fn)
	cmp_res_t compare(const std::string& fn);
	cmp_res_t compare(const vvs_t& h);

	std::tuple<double, double, double, double> scores(const cmp_res_t& stat);

private:
	vvs_t read_topo(std::istream& is, const size_t n);
private:
	std::string fn;
	vvs_t g;
	size_t n_node;
};

