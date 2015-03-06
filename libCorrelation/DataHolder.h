#pragma once
#include "SpikeTrains.h"
#include "SCV.h"
#include <string>
#include <vector>
#include <functional>

class DataHolder
{
public:
	DataHolder(const tp_t window_size, const tp_t start, const tp_t end, const std::string& fn);
	DataHolder(const tp_t window_size, const tp_t start, const tp_t end, const SpikeTrains& sts);
	DataHolder(const tp_t window_size, const tp_t start, const tp_t end, SpikeTrains&& sts);

	double pearson_correlatino(const SCV& first, const SCV& second);
	double pearson_correlatino(const size_t first, const size_t second);
	double pearson_correlatino(const size_t first, const std::vector<size_t>& second);


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

	std::vector<SCV> cont;
	SpikeTrains sts;

};

