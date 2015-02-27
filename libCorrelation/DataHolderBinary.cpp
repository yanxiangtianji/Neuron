#include "DataHolderBinary.h"

using namespace std;

DataHolderBinary::DataHolderBinary(const tp_t window_size, const tp_t start, const tp_t end, const string& fn)
	:window_size(window_size), start_t(start), end_t(end), sts(fn)
{
	_init(sts);
}

DataHolderBinary::DataHolderBinary(const tp_t window_size, const tp_t start, const tp_t end, const SpikeTrains& sts)
	: window_size(window_size), start_t(start), end_t(end), sts(sts)
{
	_init(sts);
}

DataHolderBinary::DataHolderBinary(const tp_t window_size, const tp_t start, const tp_t end, SpikeTrains&& sts)
	: window_size(window_size), start_t(start), end_t(end), sts(sts)
{
	_init(sts);
}

void DataHolderBinary::_init(const SpikeTrains& sts){
	for(const SpikeTrains::SpikeTrain& st : sts.get()){
		cont.push_back(SCVBinary(window_size, start_t, end_t, st));
	}
	cont.shrink_to_fit();
}


double DataHolderBinary::cor_dp(const SCVBinary& first, const SCVBinary& second){
	double m = first.get_length();
	return dot_product(first, second) / m;
}
double DataHolderBinary::cor_dp(const size_t first, const size_t second){
	if(first == second)
		return 1.0;
	return cor_dp(cont[first], cont[second]);
}
double DataHolderBinary::cor_dp(const size_t first, const std::vector<size_t>& second){
	std::vector<reference_wrapper<const SCVBinary>> temp;
	for(size_t idx : second)
		temp.push_back(cref(cont[idx]));
	return cor_dp(cont[first], SCVBinary::union_v(temp));
}

double DataHolderBinary::cor_dp_f(const SCVBinary& first, const SCVBinary& second){
	size_t m = first.get_sum();
	return m == 0 ? 0.0 : dot_product(first, second, 
			[](const uint8_t lth, const uint8_t rth)->uint8_t{return lth == 1 && rth == 1?1:0; }
		)
		/ static_cast<double>(m);
}
double DataHolderBinary::cor_dp_f(const size_t first, const size_t second){
	if(first == second)
		return 1.0;
	return cor_dp_f(cont[first], cont[second]);
}
double DataHolderBinary::cor_dp_f(const size_t first, const std::vector<size_t>& second){
	std::vector<reference_wrapper<const SCVBinary>> temp;
	for(size_t idx : second)
		temp.push_back(cref(cont[idx]));
	return cor_dp_f(cont[first], SCVBinary::union_v(temp));
}


size_t DataHolderBinary::dot_product(const SCVBinary& lth, const SCVBinary& rth){
	size_t res=0;
	size_t n = lth.get_length();
	for(size_t i = 0; i < n; ++i){
		res += andor(lth[i], rth[i]);
	}
	return res;
}

size_t DataHolderBinary::dot_product(const SCVBinary& lth, const SCVBinary& rth,
	std::function<uint8_t(const uint8_t, const uint8_t)> inner)
{
	size_t res = 0;
	size_t n = lth.get_length();
	for(size_t i = 0; i < n; ++i){
		res += inner(lth[i], rth[i]);
	}
	return res;
}

std::pair<size_t, size_t> DataHolderBinary::check_cospike(
	const size_t& poss_pnt, const size_t& poss_chd, const tp_t delay_th, const tp_t st_t, const tp_t end_t)
{
	return sts.check_cospike(poss_pnt, poss_chd, delay_th, st_t, end_t);
}

std::pair<size_t, size_t> DataHolderBinary::check_cospike(const size_t& poss_pnt, const size_t& poss_chd, const tp_t delay_th, const size_t idx){
	tp_t p_start = cont[poss_chd].cal_time_start(idx);
	tp_t p_end = p_start + window_size;
	return check_cospike(poss_pnt, poss_chd, delay_th, p_start, p_end);
}

std::pair<size_t, size_t> DataHolderBinary::check_cospike(const size_t& poss_pnt, const size_t& poss_chd, const tp_t delay_th){
	return check_cospike(poss_pnt, poss_chd, delay_th, start_t, end_t);
}