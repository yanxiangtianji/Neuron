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

	double cor_dp(const SCVBinary& first, const SCVBinary& second);
	double cor_dp(const size_t first, const size_t second);
	double cor_dp(const size_t first, const std::vector<size_t>& second);
	double cor_dp_f(const SCVBinary& first, const SCVBinary& second);
	double cor_dp_f(const size_t first, const size_t second);
	double cor_dp_f(const size_t first, const std::vector<size_t>& second);

	size_t get_num()const { return cont.size(); }
	tp_t get_window_size()const{ return window_size; }
	tp_t get_start_t()const{ return start_t; }
	tp_t get_end_t()const{ return end_t; }
private:
	void _init(const SpikeTrains& sts);

private:
	tp_t window_size;
	tp_t start_t, end_t;

	std::vector<SCVBinary> cont;

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
