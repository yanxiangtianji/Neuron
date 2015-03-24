#pragma once
#include <string>
#include <vector>
#include <ostream>
#include "AlgBase.h"
#include "../libCorrelation/DataHolder.h"

//Pearson correlation on delta spike count vector
class SecondAlg
	:public AlgBase
{
public:	//typedef
	//possible edge matrix type
	typedef std::vector<std::vector<bool> > ppm_t;
	//parent set type
	typedef std::vector<size_t> ps_t;
public:	//interface
	SecondAlg(const tp_t window_size, const tp_t start, const tp_t end, const std::string& fn);

	/*!
	@param cor_th: minimum acceptable correlation
	*/
	void set_mpps(const double cor_th);
	void set_ps_by_mpps();

	size_t size()const{ return dh.size(); }

private:	//helper fun
	//update dh to delta spike count vector
	void _init();

	//cor_th: minimum correlation
	ppm_t cal_by_cor(const double cor_th);

private:	//data member
	DataHolder dh;	//spike-count vector -> delta spike-count vector
};

