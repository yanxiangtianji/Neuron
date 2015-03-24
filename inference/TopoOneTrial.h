#pragma once
#include <string>
#include <vector>
#include <ostream>
#include "AlgBase.h"

class TopoOneTrial
{
public:
	TopoOneTrial(const std::string& fn, const int t_start,const int t_end,
		const int period, const int t_window, const int amp2ms);
	void set_param(const double cor_th){ this->cor_th = cor_th; }

	void go();
	void gen_static_structure();

	size_t size()const { return (time_end - time_start) / period; }
	AlgBase::pss_t get_static_structure()const{ return static_s; }
	AlgBase::pss_t get_structure(const size_t idx)const{ return cont[idx]; }

private:
	AlgBase::pss_t infer(const size_t idx);

private:
	int time_start, time_end, period;
	int time_window;
	int amp2ms;
	std::string fn;

	//parameter for SecondAlg
	double cor_th;

	std::vector<AlgBase::pss_t> cont;
	AlgBase::pss_t static_s;
};

