#include <fstream>
#include <stdexcept>
#include <algorithm>
#include "CompareTopo.h"

using namespace std;


CompareTopo::CompareTopo(const std::string& fn)
	:fn(fn)
{
	ifstream fin(fn);
	if(!fin){
		throw invalid_argument("Cannot open file " + fn);
	}
	size_t n_node, n_edge;
	fin >> n_node >> n_edge;
	g = read_topo(fin, n_node);
	fin.close();
	n_node = g.size();
}

std::vector<std::vector<size_t>> CompareTopo::read_topo(std::istream& is, const size_t n){
	vvs_t cont;
	cont.resize(n);
	for(size_t i = 0; i < n; ++i){
		size_t id, m;
		is >> id >> m;
		for(size_t j = 0; j < m; ++j){
			size_t t;
			is >> t;
			cont[id].push_back(t);
		}
		cont[i].shrink_to_fit();
		sort(cont[id].begin(), cont[id].end());
	}
	return cont;
}

CompareTopo::cmp_res_t CompareTopo::compare(const std::string& fn){
	ifstream fin(fn);
	if(!fin){
		throw invalid_argument("Cannot open file " + fn);
	}
	size_t n;
	fin >> n;
	if(n_node != n){
		throw invalid_argument("Number of node do not match.");
	}
	vvs_t cont = read_topo(fin, n);
	return compare(cont);
}

CompareTopo::cmp_res_t CompareTopo::compare(const vvs_t& h){
	vvs_t more(n_node), less(n_node);
	std::vector<size_t> matched(n_node);
	for(size_t idx = 0; idx < n_node; ++idx){
		const vector<size_t>& ref = g[idx];
		const vector<size_t>& ipt = h[idx];
		size_t& mc = matched[idx];
		size_t i = 0, j = 0;
		for(; i < ref.size() && j < ipt.size(); ++i, ++j){
			if(ref[i] == ipt[j]){
				++mc;
			} else if(ref[i] < ipt[j]){
				less[idx].push_back(ref[i]);
			} else{
				more[idx].push_back(ipt[j]);
			}
		}
	}
	return make_tuple(move(matched), move(more), move(less));
}

std::tuple<double, double, double, double> CompareTopo::scores(const cmp_res_t& stat){

}
