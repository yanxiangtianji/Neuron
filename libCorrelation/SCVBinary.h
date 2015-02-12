#pragma once
#include "def.h"
#include "SpikeTrains.h"
#include <vector>
#include <cstdint>

class SCVBinary
{
public:
	SCVBinary(const tp_t window_size, const tp_t start, const tp_t end, const SpikeTrains::SpikeTrain& st);

private:
	void _init(const SpikeTrains::SpikeTrain& st);
	void set_length();
	size_t cal_idx(const tp_t t){ return size_t((t-start)/window_size); }

private:
	tp_t start, end;
	tp_t window_size;

	size_t length;
	std::vector<uint8_t> vec;
	size_t sum;
/*static:*/
public:
	static size_t cal_length(const tp_t window_size, const tp_t start, const tp_t end);
};

