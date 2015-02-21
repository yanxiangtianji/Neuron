#pragma once
#include <random>
#include <limits>
#include <stdexcept>

template <typename T = double>
class pld_store_urng
{
private:
	typedef std::uniform_real_distribution<double> urng_type;
public:
	typedef T	result_type;
	struct param_type{
		T xmin; double alpha;
		double _exp;	//short cut for random value generating.
		explicit param_type(T xmin, double alpha){ init(xmin, alpha); }
		void init(T xmin, double alpha){
			if(xmin < 1)
				throw std::invalid_argument("invalid argument xmin (<1) for power_law_distribution");
			if(alpha <= 1)
				throw std::invalid_argument("invalid argument alpha (<=1) for power_law_distribution");
			this->xmin = xmin;
			this->alpha = alpha;
			_exp = 1.0 / (1 - alpha);
		}
	};

public:
	explicit pld_store_urng(T xmin = 1, double alpha = 2.5) :urng(), par(xmin, alpha){}

	template<class Engine>
	result_type operator()(Engine& g){ return eval(g, par); }

private:
	template <class Engine>
	result_type eval(Engine& eng, const param_type& par) const{
		urng_type::result_type y = urng(eng);
		return static_cast<result_type>(par.xmin*std::pow(1.0 - y, par._exp));
	}

private:
	urng_type urng;
	param_type par;
};

template <typename T = double>
class pld_dyn_urng
{
private:
	typedef std::uniform_real_distribution<double> urng_type;
public:
	typedef T	result_type;
	struct param_type{
		T xmin; double alpha;
		double _exp;	//short cut for random value generating.
		explicit param_type(T xmin, double alpha){ init(xmin, alpha); }
		void init(T xmin, double alpha){
			if(xmin < 1)
				throw std::invalid_argument("invalid argument xmin (<1) for power_law_distribution");
			if(alpha <= 1)
				throw std::invalid_argument("invalid argument alpha (<=1) for power_law_distribution");
			this->xmin = xmin;
			this->alpha = alpha;
			_exp = 1.0 / (1 - alpha);
		}
	};

public:
	explicit pld_dyn_urng(T xmin = 1, double alpha = 2.5) : par(xmin, alpha){}

	template<class Engine>
	result_type operator()(Engine& g){ return eval(g, par); }

private:
	template <class Engine>
	result_type eval(Engine& eng, const param_type& par) const{
		urng_type urng;
		return static_cast<result_type>(par.xmin*std::pow(1.0 - urng(eng), par._exp));
	}

private:
	param_type par;
};
