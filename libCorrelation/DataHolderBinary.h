#pragma once
#include "SpikeTrains.h"
#include "SCVBinary.h"
#include <string>
#include <vector>
#include <functional>

class DataHolderBinary
{
public:
	DataHolderBinary(const tp_t window_size, const tp_t start, const tp_t end, const std::string& fn);
	DataHolderBinary(const tp_t window_size, const tp_t start, const tp_t end, const SpikeTrains& sts);
	DataHolderBinary(const tp_t window_size, const tp_t start, const tp_t end, SpikeTrains&& sts);

	double cor_dp(const SCVBinary& first, const SCVBinary& second);
	double cor_dp(const size_t first, const size_t second);
	double cor_dp(const size_t first, const std::vector<size_t>& second);
	double cor_dp_f(const SCVBinary& first, const SCVBinary& second);
	double cor_dp_f(const size_t first, const size_t second);
	double cor_dp_f(const size_t first, const std::vector<size_t>& second);

	/*!
	@brief Find how many spikes of poss_pnt in range [st_t, end_t] have a corresponding spike within time delay_th on spike train poss_chd.
	@details See SpikeTrains.check_cospike
	@return pair(the num of countted spikes in poss_pnt, the num of qualified spikes in poss_chd).
	*/
	std::pair<size_t,size_t> check_cospike(const size_t& poss_pnt, const size_t& poss_chd, 
		const tp_t delay_th, const tp_t st_t, const tp_t end_t);
	//in the all time
	std::pair<size_t, size_t> check_cospike(const size_t& poss_pnt, const size_t& poss_chd, const tp_t delay_th);
	//in the period of idx-th window
	std::pair<size_t, size_t> check_cospike(const size_t& poss_pnt, const size_t& poss_chd,
		const tp_t delay_th, const size_t idx);

	size_t size()const { return cont.size(); }
	tp_t get_window_size()const{ return window_size; }
	tp_t get_start_t()const{ return start_t; }
	tp_t get_end_t()const{ return end_t; }
private:
	void _init(const SpikeTrains& sts);
	size_t cal_idx(const tp_t t){ return size_t((t - start_t) / window_size); }
	tp_t cal_time_start(const size_t idx){ return idx*window_size + start_t; }

private:
	tp_t window_size;
	tp_t start_t, end_t;

	std::vector<SCVBinary> cont;
	SpikeTrains sts;

/*static:*/
public:
	static size_t dot_product(const SCVBinary& lth, const SCVBinary& rth);
	static size_t dot_product(const SCVBinary& lth, const SCVBinary& rth,
		std::function<uint8_t(const uint8_t, const uint8_t)> inner);
	static uint8_t andor(const uint8_t lth, const uint8_t rth);
};

inline uint8_t DataHolderBinary::andor(const uint8_t lth, const uint8_t rth){
	return lth==rth ? 1 : 0;
}
