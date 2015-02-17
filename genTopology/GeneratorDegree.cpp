#include "GeneratorDegree.h"
#include <random>
#include <string>
#include <algorithm>
#include <stdexcept>
#include <chrono>

using namespace std;

GeneratorDegree::GeneratorDegree(const size_t num_node, const DegreeType type, 
	const bool allow_loop, const size_t shuffle_threshold)
	:n_node(num_node), type(type), allow_loop(allow_loop), SHUFFLE_THRESHOLD(shuffle_threshold)
{
	auto seed = chrono::system_clock::now().time_since_epoch().count();
	_random_gen.seed(static_cast<unsigned long>(seed));
	node_random_gen = bind(uniform_int_distribution<size_t>(0,n_node-1),_random_gen);
	set_fun_shuffle_gen();
	set_fun_enum_gen();
}

GeneratorDegree::add_fun_t GeneratorDegree::get_add_fun(AdjGraph& g){
	using namespace placeholders;
	if(type == DegreeType::INDEGREE)
		return bind(&AdjGraph::add_parent, ref(g), _1, _2);
//		return bind(&AdjGraph::add_parent, _1, _2, _3);
	else
		return bind(&AdjGraph::add_child, ref(g), _1, _2);
//		return bind(&AdjGraph::add_child, _1, _2, _3);
}
void GeneratorDegree::set_fun_shuffle_gen(){
	using namespace placeholders;
	if(allow_loop == true)
		shuffle_gen = bind(&GeneratorDegree::shuffle_gen_nsl, this, _1, _2, _3, _4);
	else
		shuffle_gen = bind(&GeneratorDegree::shuffle_gen_nl, this, _1, _2, _3, _4);
}
void GeneratorDegree::set_fun_enum_gen(){
	using namespace placeholders;
	if(allow_loop == true)
		enum_gen = bind(&GeneratorDegree::enum_gen_nsl, this, _1, _2, _3, _4);
	else
		enum_gen = bind(&GeneratorDegree::enum_gen_nl, this, _1, _2, _3, _4);
}


void GeneratorDegree::shuffle_gen_nsl(vector<size_t>& sf_vec, const size_t idx, const size_t m, add_fun_bind_t add){
	//random_shuffle(sf_vec.begin(), sf_vec.end());
	shuffle(sf_vec.begin(), sf_vec.end(), _random_gen);
	size_t pick_n = m;
	for(size_t j = 0; j < pick_n; ++j){
		if(sf_vec[j] == idx){
			++pick_n;
			continue;
		}
		add(sf_vec[j]);
	}
}
void GeneratorDegree::shuffle_gen_nl(vector<size_t>& sf_vec, const size_t idx, const size_t m, add_fun_bind_t add){
	size_t t = 0;
	generate_n(sf_vec.begin(), idx, [&](){return t++; });
	random_shuffle(sf_vec.begin(), sf_vec.begin()+idx);
	size_t pick_n = m;
	for(size_t j = 0; j < pick_n; ++j){
		if(sf_vec[j] == idx){
			++pick_n;
			continue;
		}
		add(sf_vec[j]);
	}
}


void GeneratorDegree::enum_gen_nsl(vector<bool>& used, const size_t idx, const size_t m, add_fun_bind_t add)
{
	used.assign(n_node, false);
	used[idx] = true;
	for(size_t j = 0; j < m; j++){
		size_t t;
		do{
			t = node_random_gen();
		} while(used[t]);
		used[t] = true;
		add(t);
	}
}
void GeneratorDegree::enum_gen_nl(vector<bool>& used, const size_t idx, const size_t m, add_fun_bind_t add)
{
	used.assign(n_node, false);
	used[idx] = true;
	uniform_int_distribution<size_t> rgen(0, idx - 1);
	for(size_t j = 0; j < m; j++){
		size_t t;
		do{
			t = rgen(_random_gen);
		} while(used[t]);
		used[t] = true;
		add(t);
	}
}

bool GeneratorDegree::check_degree(const std::vector<size_t>& degree){
	if(!_check_degree_construct(degree))
		return false;
	if(allow_loop)
		return true;
	else
		return _check_degree_dag(degree);
}
bool GeneratorDegree::_check_degree_construct(const std::vector<size_t>& degree){
	const size_t max_n = n_node - 1;
	for(const size_t& t : degree){
		if(t > max_n)
			return false;
	}
	return true;
}
bool GeneratorDegree::_check_degree_dag(const std::vector<size_t>& degree){
/*	vector<size_t> ordered(degree);
	sort(ordered.begin(), ordered.end());
	for(size_t i = 0; i < ordered.size(); ++i)
		if(ordered[i]>i)
			return false;
	return true;
*/
	vector<size_t> count(n_node, 0);
	for(const size_t& t : degree)
		++count[t];
	size_t pos = 0;
	for(size_t i = 0; i < count.size(); ++i){
		pos += count[i];
		if(pos < i + 1)//pos-1
			return false;
	}
	return true;
}

std::vector<size_t> GeneratorDegree::prepare_degree_for_dag(const std::vector<size_t>& degree){
	vector<size_t> vec(degree);
	sort(vec.begin(), vec.end());
	return vec;
}

AdjGraph GeneratorDegree::gen_nl(const std::vector<size_t>& degree){
	using placeholders::_1;
	if(!check_degree(degree)){
		throw invalid_argument("Given degree list cannot form a required graph.");
	}
	const size_t max_od = n_node - 1;	//maximum out-degree
	vector<size_t> deg = prepare_degree_for_dag(degree);

	vector<size_t> sf_vec;	//shuffle vector. For alg_1: random shuffle a list and pick first m
	vector<bool> used;	//used vector. For alg_2: random generating unique m

	AdjGraph g(n_node);
	add_fun_t add_fun = get_add_fun(g);
	for(size_t i = 0; i < n_node; ++i){
		size_t m = deg[i];
		if(m > max_od){
			throw invalid_argument("Given degree of node(" + to_string(i) + ") is " + to_string(m)
				+ " which exceeds maximum possible degree.");
		}
		if(m == 0){
			//do nothing
		} else if(m==i){
			for(size_t j = 0; j < m; ++j)
				add_fun(i, j);
		} else if(_is_shuffle_better(m)) {
			//shuffle a continuous list and pick the first m
			if(sf_vec.empty())
				sf_vec.resize(n_node);
			shuffle_gen_nl(sf_vec, i, m, bind(add_fun,i,_1));
		} else{
			//mark and re-generate
			enum_gen_nl(used, i, m, bind(add_fun,i,_1));
		}//end if
	}
	return g;
}



// Generate $n_edge[i]$ edges for each node $i$, randomly connect to other nodes.
AdjGraph GeneratorDegree::gen(const std::vector<size_t>& deg){
	using placeholders::_1;
	if(!check_degree(deg)){
		throw invalid_argument("Given degree list cannot form a required graph.");
	}
	const size_t max_od = n_node - 1;	//maximum out-degree

	vector<size_t> sf_vec;	//shuffle vector. For alg_1: random shuffle a list and pick first m
	vector<bool> used;	//used vector. For alg_2: random generating unique m

	AdjGraph g(n_node);
	add_fun_t add_fun = get_add_fun(g);
	for(size_t i = 0; i < n_node; ++i){
		size_t m = deg[i];
		if(m > max_od){
			throw invalid_argument("Given degree of node(" + to_string(i) + ") is " + to_string(m)
				+ " which exceeds maximum possible degree.");
		}
		if(m == 0){
			//do nothing
		}else if(_is_shuffle_better(m)) {
			//shuffle a continuous list and pick the first m
			if(sf_vec.empty()){//first use the shuffle vector
				sf_vec.reserve(n_node);
				size_t t = 0;
				generate_n(back_inserter(sf_vec), n_node, [&t](){return t++; });
			}
			shuffle_gen_nsl(sf_vec, i, m, bind(add_fun,i,_1));
		} else{
			//mark and re-generate
			enum_gen_nsl(used, i, m, bind(add_fun,i,_1));
		}//end if
	}
	return g;
}


// Generate out-degree by $fun_out_degree$, randomly connect to other nodes.
AdjGraph GeneratorDegree::gen(std::function<size_t(const size_t nid)> fun_degree)
{
	vector<size_t> v;
	v.reserve(n_node);
	for(size_t i = 0; i < n_node; ++i)
		v.push_back(fun_degree(i));
	return gen(v);
}

// Generate out-degree by $n_edge$ * (fun_por_degree(i)/sum of all fun_por_degree(i))$, randomly connect to other nodes.
AdjGraph GeneratorDegree::gen(const size_t n_edge, std::function<double(const size_t nid)> fun_por_degree)
{
	const size_t max_od = n_node - 1;
	if(n_edge > max_od*n_node){
		throw invalid_argument("Total out-degree(" + to_string(n_edge) +
			") exceeds maximum possible out-degree(" + to_string(max_od*n_node) + ").");
	}
	double sum = 0.0;
	vector<double> temp;
	temp.reserve(n_node);
	for(size_t i = 0; i < n_node; ++i){
		double t = max(0.0, fun_por_degree(i));
		temp.push_back(t);
		sum += t;
	}
	vector<size_t> v;
	v.reserve(n_node);
	size_t n_sum = 0;
	for(size_t i = 0; i < n_node - 1; ++i){
		size_t t = static_cast<size_t>(round(n_edge * temp[i] / sum));
		t = min(t, max_od);
		v.push_back(t);
		n_sum += t;
	}
	v.push_back(n_sum >= n_edge ? 0 : n_edge - n_sum);
	return gen(v);
}

