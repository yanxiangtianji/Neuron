#include "AdjGraphSec.h"


AdjGraphSec::AdjGraphSec(const size_t n_node):Graph(n_node)
{
	cont.resize(n_node);
}

bool AdjGraphSec::add(const size_t from, const size_t to){
	bool t= (from > n || to > n)? false : cont[from].insert(to).second;
	return t ? ++m, true : false;
}

bool AdjGraphSec::remove(const size_t from, const size_t to){
	bool t= (from > n || to > n) ? false : cont[from].erase(to)==1;
	return t ? --m, true : false;
}

std::ostream& AdjGraphSec::output(std::ostream& os) const{
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
