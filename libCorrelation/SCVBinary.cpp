#include "SCVBinary.h"
#include <numeric>
#include <algorithm>

using namespace std;

SCVBinary::SCVBinary(const tp_t window_size, const tp_t start, const tp_t end, const SpikeTrains::SpikeTrain& st)
	:start(start), end(end), window_size(window_size), sum(0)
{
	_init(st);
}

void SCVBinary::set_length(){
	length = cal_length(window_size, start, end);
}

size_t SCVBinary::cal_length(const tp_t window_size, const tp_t start, const tp_t end){
	return static_cast<size_t>(ceil(double(end - start) / window_size));
}

void SCVBinary::_init(const SpikeTrains::SpikeTrain& st){
	sum = 0;
	set_length();
	vec.resize(length, 0);
	for(const auto& t : st){
		size_t idx = cal_idx(t);
		if(idx >= length)
			break;
		vec[idx] = 1;
	}
	sum = accumulate(vec.begin(), vec.end(), 0);
}

SCVBinary SCVBinary::union_v(const std::vector<std::reference_wrapper<const SCVBinary>>& org){
	SCVBinary res(org[0].get());
	size_t length = res.get_length();
	for(size_t i = 1; i < org.size(); ++i){
		const SCVBinary& scv=org[i];
		for(size_t j = 0; j < length; ++j){
			if(scv[j] != 0)
				res.vec[j] = 1;
		}
	}
	return res;
}

SCVBinary SCVBinary::union_v(const SCVBinary& lth, const SCVBinary& rth){
	SCVBinary res(lth);
	size_t length = res.get_length();
	for(size_t j = 0; j < length; ++j){
		if(rth[j] != 0)
			res.vec[j] = 1;
	}
	return res;
}

