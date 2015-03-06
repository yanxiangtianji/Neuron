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
	DataHolder(const tp_t window_size, const tp_t start, const tp_t end, const std::vector<SCV>& cont);
	DataHolder(const tp_t window_size, const tp_t start, const tp_t end, std::vector<SCV>&& cont);

	double pearson_correlation(const SCV& first, const SCV& second);
	double pearson_correlation(const size_t first, const size_t second);
	double pearson_correlation(const size_t first, const std::vector<size_t>& second);


	size_t size()const { return cont.size(); }
	tp_t get_window_size()const{ return window_size; }
	tp_t get_start_t()const{ return start_t; }
	tp_t get_end_t()const{ return end_t; }
	std::vector<SCV>& get_cont(){ return cont; }
	const std::vector<SCV>& get_cont()const{ return cont; }
	SCV& operator[](const size_t idx){ return cont[idx]; }
	const SCV& operator[](const size_t idx)const { return cont[idx]; }

	void set_cont(const std::vector<SCV>& c){ cont = c; }
	void set_cont(std::vector<SCV>&& c){ cont = c; }
private:
	void _init(const SpikeTrains& sts);
	size_t cal_idx(const tp_t t){ return size_t((t - start_t) / window_size); }
	tp_t cal_time_start(const size_t idx){ return idx*window_size + start_t; }

private:
	tp_t window_size;
	tp_t start_t, end_t;

	std::vector<SCV> cont;

};

