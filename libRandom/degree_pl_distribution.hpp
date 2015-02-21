#pragma once
#include <type_traits>
#include "power_law_distribution.hpp"

template <typename IntType = int>
class degree_pl_distribution
	: public power_law_distribution<IntType>
{
	static_assert(std::is_integral<IntType>::value, "invalid template argument for degree_pl_distribution");
public:
	typedef IntType result_type;
public:
	explicit degree_pl_distribution(size_t n, double alpha) :power_law_distribution(1, alpha), _n(n){
		if(n <= 0)
			throw std::invalid_argument("invalid argument n (<=0) for degree_pl_distribution");
	}

	result_type min()const{ return 0; }
	result_type max()const{ return _n-1; }

	result_type n()const{ return _n; }
	result_type xmin()const{ return par.xmin; }
	double alpha()const{ return par.alpha; }

	template<class Engine>
	result_type operator()(Engine& eng){
		result_type t = power_law_distribution::operator()(eng)-1;//move offset, to make starting point at 0
		return static_cast<result_type>(t < _n ? t : _n - 1);
//		return static_cast<result_type>(t < _n ? t : 0);
	}

private:
	size_t _n;
};

