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
		vec[cal_idx(t)] = 1;
	}
	sum = accumulate(vec.begin(), vec.end(), 0);
}
