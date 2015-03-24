#pragma once
#include <string>
#include <vector>
#include <ostream>
#include "AlgBase.h"
#include "../libCorrelation/DataHolderBinary.h"

//excitatory dot product on binary spike vector
class FirstAlg
	: public AlgBase
{
public:	//interface
	FirstAlg(const tp_t window_size, const tp_t start, const tp_t end, const std::string& fn);

	/*!
	@param cor_th: minimum acceptable correlation;
	@param delay_th: maximum acceptable delay length;
	@param cospike_dif_tol: minimum acceptable fraction of co-spikes
	*/
	void set_mpps_param(const tp_t delay_th, const double cospike_dif_tol){
		_mpps_param_delay_th = delay_th; _mpps_param_cospike_dif_tol = cospike_dif_tol; }
	void set_mpps(const double cor_th);
	void set_ps_by_mpps();
	
	size_t size()const{ return dh.size(); }

private:	//helper fun
	//cor_th: minimum correlation
	ppm_t cal_by_cor(const double cor_th);
	//delay_th: maximum delay length; cospike_dif_tol: minimum fraction of co-spike
	void refine_ppm_by_delay(ppm_t& ppm, const tp_t delay_th, const double cospike_dif_tol);

private:	//data member
	DataHolderBinary dh;
	//parameters for mpps:
	tp_t _mpps_param_delay_th;
	double _mpps_param_cospike_dif_tol;
};

