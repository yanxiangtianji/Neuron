#pragma once
#include <random>
#include <functional>
#include "def.h"

class ToolRandom
{
private:
	template<typename TARGET, typename SOURCE>
	static TARGET trans(const SOURCE& s){ return static_cast<TARGET>(s); }
	template<typename T>
	static T min(const T& a, const T& b){ return a <= b ? a : b; }
	template<typename T>
	static T max(const T& a, const T& b){ return a >= b ? a : b; }
public:
	static int get();
	static int get_int(const int min, const int max);
	static float get_float(const float min, const float max);
	static double get_double(const double min, const double max);

	static double dist_normal(const double mean=0.0, const double variance=1.0);

	template<typename RES, class DIS>
	static std::function<RES()> bind_gen(DIS dis){
		return std::bind(trans<RES, typename DIS::result_type>, bind(dis, ref(gen)));
	};
	template<class RES>
	static std::function<RES()> bound_min(const RES min_bound, std::function<RES()> gen);
	template<class RES>
	static std::function<RES()> bound_max(const RES max_bound, std::function<RES()> gen);
	template<class RES>
	static std::function<RES()> bound_minmax(const RES min_bound, RES max_bound, std::function<RES()> gen);

	template<typename RES, class DIS>
	static std::function<RES()> bind_gen_bmin(const RES min_bound, DIS dis){
		return bound_min<RES>(min_bound, bind_gen<RES>(dis));
	}
	template<typename RES, class DIS>
	static std::function<RES()> bind_gen_bmax(const RES max_bound, DIS dis){
		return bound_max<RES>(max_bound, bind_gen<RES>(dis));
	}
	template<typename RES, class DIS>
	static std::function<RES()> bind_gen_bminmax(const RES min_bound, const RES max_bound, DIS dis){
		return bound_minmax<RES>(min_bound, max_bound, bind_gen<RES>(dis));
	}

private:
//	static std::random_device gen;
//	static std::mt19937 gen;
	static std::default_random_engine gen;
};

template<class RES>
inline static std::function<RES()> ToolRandom::bound_min(const RES min_bound, std::function<RES()> gen){
	return bind(max<RES>, min_bound, bind(gen));
}
template<class RES>
inline static std::function<RES()> ToolRandom::bound_max(const RES max_bound, std::function<RES()> gen){
	return bind(min<RES>, max_bound, bind(gen));
}
template<class RES>
inline static std::function<RES()> ToolRandom::bound_minmax(const RES min_bound, RES max_bound, std::function<RES()> gen){
	if(min_bound > max_bound){
		throw exception("Invalid: min_bound is larger than max_bound");
	}
	return bound_min<RES>(min_bound, bound_max<RES>(max_bound, gen));
}

