#pragma once
#include <istream>
#include <string>
#include <vector>
#include <tuple>

class CompareTopo
{
	typedef std::vector<size_t> vs_t;
	typedef std::vector<std::vector<size_t> > vvs_t;
	typedef std::vector<std::tuple<size_t, vs_t, vs_t> > cmp_res_t;	//matched, added, lost
public:
	struct ConfusionMatix{
		size_t tp, tn, fn, fp;
		ConfusionMatix(const size_t tp, const size_t tn, const size_t fn, const size_t fp)
			:tp(tp), tn(tn), fn(fn), fp(fp){}
	};
	struct StatScore{
		double precision, recall, f1, accurancy;
		StatScore(const double p, const double r, const double f, const double a)
			:precision(p), recall(r), f1(f), accurancy(a){}
	};
public:
	CompareTopo(const std::string& fn);

	//return difference of each neuron's parent (# of matched, new in fn, lost in fn)
	cmp_res_t compare(const std::string& fn);
	cmp_res_t compare(const vvs_t& h);

	ConfusionMatix cmatrix(const cmp_res_t& stat);
	StatScore scores(const ConfusionMatix& cm);
	StatScore scores(const cmp_res_t& stat);

private:
	vvs_t read_topo(std::istream& is, const size_t n);
private:
	std::string fn;
	vvs_t g;
	size_t n_node;
};

