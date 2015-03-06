#pragma once
#include <string>
#include <vector>
#include <ostream>
#include "../libCorrelation/DataHolder.h"

class SecondAlg
{
public:	//typedef
	//possible edge matrix type
	typedef std::vector<std::vector<bool> > ppm_t;
	//parent set type
	typedef std::vector<size_t> ps_t;
public:	//interface
	SecondAlg(const tp_t window_size, const tp_t start, const tp_t end, const std::string& fn);

	// cor_th: minimum acceptable correlation
	void set_ps(const double cor_th);

	size_t size()const{ return dh.size(); }
	const std::vector<std::vector<size_t> >& get_ps()const{ return ps; }
	void output_ps(std::ostream& os){ output_vps(os, ps); }

private:	//helper fun
	//update dh to delta spike count vector
	void _init();

	//cor_th: minimum correlation
	ppm_t cal_by_cor(const double cor_th);
	void set_ps_by_ppm(ppm_t& ppm);

private:	//data member
	DataHolder dh;	//spike-count vector -> delta spike-count vector
	//Maximum sized Possible Parent Set
	std::vector<ps_t> ps;

	/*static:*/
private:
	static void output_vps(std::ostream& os, const std::vector<ps_t>& vps);

};

