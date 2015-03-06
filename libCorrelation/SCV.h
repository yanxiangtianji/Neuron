#pragma once
#include "def.h"
#include "SpikeTrains.h"
#include <vector>

class SCV
{
public:
	typedef int value_type;
public:
	SCV(const tp_t window_size, const tp_t start, const tp_t end, const SpikeTrains::SpikeTrain& st);

	size_t cal_idx(const tp_t t){ return size_t((t - start) / window_size); }
	tp_t cal_time_start(const size_t idx){ return idx*window_size + start; }

	value_type operator[](const size_t idx)const{ return vec[idx]; }
	size_t get_length()const{ return length; }
	const std::vector<value_type>& get_vec()const{ return vec; }
	size_t get_sum()const { return sum; }
private:
	void _init(const SpikeTrains::SpikeTrain& st);
	void set_length();

private:
	tp_t start, end;
	tp_t window_size;

	size_t length;
	std::vector<value_type> vec;
	size_t sum;
	/*static:*/
public:
	static SCV union_v(const std::vector<std::reference_wrapper<const SCV>>& org);
	static SCV union_v(const SCV& lth, const SCV& rth);
	static size_t cal_length(const tp_t window_size, const tp_t start, const tp_t end);

};

