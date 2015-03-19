#pragma once
#include "def.h"
#include "SpikeTrains.h"
#include <vector>

//spike count vector
class SCV
{
public:
	typedef int value_type;
public:
	//start and end describe which part of data will be used from st
	SCV(const tp_t window_size, const tp_t start, const tp_t end, const SpikeTrains::SpikeTrain& st);
	//the last parameter int is used to distinguish "SpikeTrains::SpikeTrain" and "std::vector<value_type>" when they are the same
//	SCV(const tp_t window_size, const tp_t start, const tp_t end, const std::vector<value_type>& vec, int);
//	SCV(const tp_t window_size, const tp_t start, const tp_t end, std::vector<value_type>&& vec, int);

	size_t cal_idx(const tp_t t){ return size_t((t - start) / window_size); }
	tp_t cal_time_start(const size_t idx){ return idx*window_size + start; }

	value_type operator[](const size_t idx)const{ return vec[idx]; }
	size_t get_length()const{ return length; }
	const std::vector<value_type>& get_vec()const{ return vec; }
	void set_start(const tp_t s){ start = s; set_length(); }
	void set_end(const tp_t e){ end = e; set_length(); }
	void set_window_size(const tp_t w){ window_size = w; set_length(); }
	bool set_vec(const std::vector<value_type>& v);
	bool set_vec(std::vector<value_type>&& v);
private:
	void _init(const SpikeTrains::SpikeTrain& st);
	void set_length();

private:
	tp_t start, end;
	tp_t window_size;

	size_t length;
	std::vector<value_type> vec;
	/*static:*/
public:
	static SCV union_v(const std::vector<std::reference_wrapper<const SCV>>& org);
	static SCV union_v(const SCV& lth, const SCV& rth);
	static size_t cal_length(const tp_t window_size, const tp_t start, const tp_t end);

};

