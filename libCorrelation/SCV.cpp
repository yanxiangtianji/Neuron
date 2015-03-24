#include "SCV.h"
#include <numeric>
#include <algorithm>

using namespace std;

SCV::SCV(const tp_t window_size, const tp_t start, const tp_t end, const SpikeTrains::SpikeTrain& st)
	:start(start), end(end), window_size(window_size)
{
	_init(st);
}
/*
SCV::SCV(const tp_t window_size, const tp_t start, const tp_t end, const std::vector<value_type>& vec, int)
	: start(start), end(end), window_size(window_size), vec(vec)
{
}
SCV::SCV(const tp_t window_size, const tp_t start, const tp_t end, std::vector<value_type>&& vec, int)
	: start(start), end(end), window_size(window_size), vec(vec)
{
}
*/

void SCV::set_length(){
	length = cal_length(window_size, start, end);
}

size_t SCV::cal_length(const tp_t window_size, const tp_t start, const tp_t end){
	return static_cast<size_t>(ceil(double(end - start) / window_size));
}

bool SCV::set_vec(const std::vector<value_type>& v){
	if(v.size() != length)
		return false;
	vec = v;
	return true;
}
bool SCV::set_vec(std::vector<value_type>&& v){
	if(v.size() != length)
		return false;
	vec = v;
	return true;
}

void SCV::_init(const SpikeTrains::SpikeTrain& st){
	set_length();
	vec.resize(length, 0);
	auto it_beg = lower_bound(st.begin(), st.end(), start);
	auto it_end = upper_bound(st.begin(), st.end(), end);
	while(it_beg != it_end){
		size_t idx = cal_idx(*it_beg++);
		++vec[idx];
	}
/*	for(const auto& t : st){
		if(t < start)
			continue;
		else if(t > end)
			break;
		size_t idx = cal_idx(t);
		++vec[idx];
	}*/
}

SCV SCV::union_v(const std::vector<std::reference_wrapper<const SCV>>& org){
	SCV res(org[0].get());
	size_t length = res.get_length();
	for(size_t i = 1; i < org.size(); ++i){
		const SCV& scv = org[i];
		for(size_t j = 0; j < length; ++j){
			res.vec[j] += scv[j];
		}
	}
	return res;
}

SCV SCV::union_v(const SCV& lth, const SCV& rth){
	SCV res(lth);
	size_t length = res.get_length();
	for(size_t j = 0; j < length; ++j){
		res.vec[j] += rth[j];
	}
	return res;
}

