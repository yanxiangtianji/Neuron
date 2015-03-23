#pragma once
#include <string>
#include <vector>
#include <ostream>
#include "AlgBase.h"
#include "AnalyzeTopo.h"

class OnRealData
{
public:
	OnRealData(const std::string base_dir, const size_t amp2ms, const size_t n_node);

	void go_one(const std::string& res_suf, const std::string& fn, const double cor_th);
	void go_batch(const std::string& res_head, const std::vector<std::string>& name_list,
		const bool with_mid, const double cor_th, const double prob_th);
	void go_multi_parameter(const std::string& res_head, const std::vector<std::string>& name_list, 
		const std::vector<double>& cor_ths, const std::vector<double>& prob_ths);

	void output_merged_result(const AnalyzeTopo::prob_g_t& pmat,
		const double prob_th, std::ostream& os_mat, std::ostream& os_adj);

	void output_merged_result(const AnalyzeTopo& anl,
		const double prob_th, std::ostream& os_mat, std::ostream& os_adj);

	void set_base_dir(const std::string& base_dir){ this->base_dir = base_dir; }
	void set_st_fld(const std::string& st_fld){ this->st_fld = st_fld; }
	void set_if_fld(const std::string& if_fld){ this->if_fld = if_fld; }
//	void set_name_list(const std::vector<std::string>& names){ this->name_list = names; }
//	void set_name_list(std::vector<std::string>&& names){ this->name_list = names; }
	void set_time_start(const int t_start){ time_start = t_start; }
	void set_time_end(const int t_end){ time_end= t_end; }

private:
	AlgBase::pss_t _load_adj(const std::string& fn);

	AlgBase::pss_t _infer(const std::string& fn_st, const std::string& fn_if,
		const bool out_if, const double cor_th);
private:
//	const int n_c1 = 54, n_c2 = 52;

	int amp2ms;
	size_t n_node;
	std::string base_dir;
	std::string st_fld, if_fld;
	int time_start, time_end;
//	std::vector<std::string> name_list;
};

