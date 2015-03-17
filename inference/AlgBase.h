#pragma once
#include <string>
#include <vector>
#include <ostream>

class AlgBase
{
public:
	//possible edge matrix type
	typedef std::vector<std::vector<bool> > ppm_t;
	//parent set type
	typedef std::vector<size_t> ps_t;
	typedef std::vector<ps_t> pss_t;

public:

	virtual void set_mpps(const double cor_th)=0;
	virtual void set_ps_by_mpps()=0;


	virtual size_t size()const = 0;
	const pss_t& get_ps()const{ return ps; }
	const pss_t& get_mpps()const{ return mpps; }
	void output_mpps(std::ostream& os){ output_vps(os, mpps); }
	void output_ps(std::ostream& os){ output_vps(os, ps); }

protected:	//helper fun
	//cor_th: minimum correlation
	virtual ppm_t cal_by_cor(const double cor_th) = 0;
	void set_mpps_by_ppm(ppm_t& ppm);
	/*3 helper might be useful for refine ppm*/
	//whether rth is contained by lth
	bool contains(const ps_t& lth, const ps_t& rth);
	bool equals(const ps_t& lth, const ps_t& rth);
	//check whether i's parents lth and j's parent rth have a loop (lth has j && rth has i)
	bool share_n_loop(const size_t i, const ps_t& lth, const size_t j, const ps_t& rth);

protected:	//data member
	//Maximum sized Possible Parent Set
	pss_t mpps;
	pss_t ps;

/*static:*/
private:
	static void output_vps(std::ostream& os, const pss_t& vps);
};

