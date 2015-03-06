#include "SCV.h"
#include <numeric>
#include <algorithm>

using namespace std;

SCV::SCV(const tp_t window_size, const tp_t start, const tp_t end, const SpikeTrains::SpikeTrain& st)
	:start(start), end(end), window_size(window_size)
{
	_init(st);
}
SCV::SCV(const tp_t window_size, const tp_t start, const tp_t end, const std::vector<value_type>& vec, int)
	: start(start), end(end), window_size(window_size), vec(vec)
{
}
SCV::SCV(const tp_t window_size, const tp_t start, const tp_t end, std::vector<value_type>&& vec, int)
	: start(start), end(end), window_size(window_size), vec(vec)
{
}

void SCV::set_length(){
	length = cal_length(window_size, start, end);
}

size_t SCV::cal_length(const tp_t window_size, const tp_t start, const tp_t end){
	return static_cast<size_t>(ceil(double(end - start) / window_size));
}

void SCV::_init(const SpikeTrains::SpikeTrain& st){
	set_length();
	vec.resize(length, 0);
	for(const auto& t : st){
		size_t idx = cal_idx(t);
		if(idx >= length)
			break;
		++vec[idx];
	}
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

