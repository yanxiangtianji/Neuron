#pragma once
#include <string>
#include <vector>
#include <ostream>
#include "../libCorrelation/DataHolderBinary.h"

class FirstAlg
{
public:	//typedef
	//possible edge matrix type
	typedef std::vector<std::vector<bool> > ppm_t;
	//parent set type
	typedef std::vector<size_t> ps_t;
public:	//interface
	FirstAlg(const tp_t window_size, const tp_t start, const tp_t end, const std::string& fn);
	/*!
	@param cor_th: minimum acceptable correlation;
	@param delay_th: maximum acceptable delay length;
	@param cospike_dif_tol: minimum acceptable fraction of co-spikes
	*/
	void set_mpps(const double cor_th, const tp_t delay_th, const double cospike_dif_tol);
	void set_ps_by_mpps();
	
	size_t size()const{ return dh.size(); }
	const std::vector<std::vector<size_t> >& get_ps()const{ return ps; }
	const std::vector<std::vector<size_t> >& get_mpps()const{ return mpps; }
	void output_mpps(std::ostream& os){ output_vps(os, mpps); }
	void output_ps(std::ostream& os){ output_vps(os, ps); }

private:	//helper fun
	//cor_th: minimum correlation
	ppm_t cal_by_cor(const double cor_th);
	//delay_th: maximum delay length; cospike_dif_tol: minimum fraction of co-spike
	void refine_ppm_by_delay(ppm_t& ppm, const tp_t delay_th, const double cospike_dif_tol);
	void set_mpps_by_ppm(ppm_t& ppm);
	//whether rth is contained by lth
	bool contains(const ps_t& lth, const ps_t& rth);
	bool equals(const ps_t& lth, const ps_t& rth);
	bool share_n_loop(const size_t i, const ps_t& lth, const size_t j, const ps_t& rth);
private:	//data member
	DataHolderBinary dh;
	//Maximum sized Possible Parent Set
	std::vector<ps_t> mpps;
	std::vector<ps_t> ps;

/*static:*/
private:
	static void output_vps(std::ostream& os, const std::vector<ps_t>& vps);
};

