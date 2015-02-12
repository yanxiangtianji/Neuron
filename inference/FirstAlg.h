#pragma once
#include <string>
#include <vector>
#include "../libCorrelation/DataHolderBinary.h"

class FirstAlg
{
public:
	//po matrix type
	typedef std::vector<std::vector<bool> > ppm_t;
public:
	FirstAlg(std::string& fn, const tp_t window_size, const tp_t start, const tp_t end);
	void set_mpps(const double cor_th, const tp_t delay_th);
	
	size_t size()const{ return dh.size(); }
private:
	ppm_t cal_by_cor(const double cor_th);
	void refine_ppm_by_delay(ppm_t& ppm, const tp_t delay_th);
	void set_mpps_by_ppm(ppm_t& ppm);
private:
	DataHolderBinary dh;
	//Maximum sized Possible Parent Set
	std::vector<std::vector<size_t> > mpps;
	std::vector<std::vector<size_t> > ps;
};

