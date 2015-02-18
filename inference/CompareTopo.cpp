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
	this->n_node = n_node;
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
	cmp_res_t res;	//matched, added, lost
	for(size_t idx = 0; idx < n_node; ++idx){
		const vector<size_t>& ref = g[idx];
		const vector<size_t>& ipt = h[idx];
		size_t mc = 0;
		vector<size_t> more, less;
		size_t i = 0, j = 0;
		while(i < ref.size() && j < ipt.size()){
			if(ref[i] == ipt[j]){
				++mc;
				++i;
				++j;
			} else if(ref[i] < ipt[j]){
				less.push_back(ref[i]);
				++i;
			} else{
				more.push_back(ipt[j]);
				++j;
			}
		}
		res.push_back(make_tuple(mc, move(more), move(less)));
	}
	return res;
}

CompareTopo::ConfusionMatix CompareTopo::cmatrix(const cmp_res_t& stat){
	size_t tp = 0, tn = 0, fn = 0, fp=0;
	for(const tuple<size_t,vector<size_t>,vector<size_t>>& temp:stat){
		tp += get<0>(temp);
		tn += get<1>(temp).size();
		fn += get<2>(temp).size();
	}
	fp = n_node*n_node - tp - tn - fn;
	return ConfusionMatix{tp,tn,fn,fp};
}


CompareTopo::StatScore CompareTopo::scores(const ConfusionMatix& cm){
	double precision, recall, f1, accurancy;
	precision = static_cast<double>(cm.tp) / (cm.tp + cm.tn);
	recall = static_cast<double>(cm.tp) / (cm.tp + cm.fn);
	f1 = 2 * precision*recall / (precision + recall);
	accurancy = static_cast<double>(cm.tp + cm.fp) / (cm.tp + cm.tn + cm.fn + cm.fp);
	return StatScore(precision, recall, f1, accurancy);
}

CompareTopo::StatScore CompareTopo::scores(const cmp_res_t& stat){
	return scores(cmatrix(stat));
}


