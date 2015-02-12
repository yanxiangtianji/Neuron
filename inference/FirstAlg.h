#pragma once
#include <string>
#include <vector>
#include <ostream>
#include "../libCorrelation/DataHolderBinary.h"

class FirstAlg
{
public:
	//possible edge matrix type
	typedef std::vector<std::vector<bool> > ppm_t;
	//parent set type
	typedef std::vector<size_t> ps_t;
public:
	FirstAlg(const tp_t window_size, const tp_t start, const tp_t end, const std::string& fn);
	void set_mpps(const double cor_th, const tp_t delay_th);
	void set_ps_by_mpps();
	
	size_t size()const{ return dh.size(); }
	const std::vector<std::vector<size_t> >& get_ps()const{ return ps; }
	const std::vector<std::vector<size_t> >& get_mpps()const{ return mpps; }
	void output_ps(std::ostream& os);

private:
	ppm_t cal_by_cor(const double cor_th);
	void refine_ppm_by_delay(ppm_t& ppm, const tp_t delay_th);
	void set_mpps_by_ppm(ppm_t& ppm);
	//whether rth is contained by lth
	bool contains(const ps_t& lth, const ps_t& rth);
	bool equals(const ps_t& lth, const ps_t& rth);

private:
	DataHolderBinary dh;
	//Maximum sized Possible Parent Set
	std::vector<ps_t> mpps;
	std::vector<ps_t> ps;
};

