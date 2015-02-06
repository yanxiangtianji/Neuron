#include "AdjGraph.h"
#include <algorithm>

AdjGraph::AdjGraph(const size_t n_node) 
	:Graph(n_node), cont(n_node), unsorted_any(false), unsorted(n_node,false){
}

bool AdjGraph::add(const size_t from, const size_t to){
	cont[from].push_back(to);
	++m;
	unsorted_any = true;
	unsorted[from] = true;
	return true;
//	return (from > n || to > n)? false : cont[from].insert(to).second;
}

bool AdjGraph::remove(const size_t from, const size_t to){
	cont[from].erase(std::find(cont[from].begin(),cont[from].end(),to));
	--m;
	unsorted_any = true;
	unsorted[from] = true;
	return true;
//	return (from > n || to > n) ? false : cont[from].erase(to)==1;
}

AdjGraph& AdjGraph::sort_up(){
	if(!unsorted_any)
		return *this;
	for(size_t i = 0; i < n; ++i){
		if(unsorted[i]){
			auto& line = cont[i];
			m -= line.size();
			std::sort(line.begin(), line.end());
			auto end = std::lower_bound(line.begin(), line.end(), n);
			end=std::unique(line.begin(), end);
			line.erase(end, line.end());
			m += line.size();
			unsorted[i] = false;
		}
	}
	unsorted_any = false;
	return *this;
}

std::ostream& AdjGraph::output(std::ostream& os) const{
	os << n << ' ' << m << '\n';
	for (size_t i = 0; i < cont.size(); ++i){
		os << i << " " << cont[i].size() << '\n';
		for (const auto& v : cont[i]){
			os << ' ' << v;
		}
		os << '\n';
	}
	return os;
}
