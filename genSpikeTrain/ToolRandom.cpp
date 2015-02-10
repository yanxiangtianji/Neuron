#include "ToolRandom.h"
#include <chrono>
using namespace std;

unsigned seed = static_cast<unsigned>(std::chrono::system_clock::now().time_since_epoch().count());
default_random_engine ToolRandom::gen = default_random_engine(seed);


int ToolRandom::get(){
	return gen();
}

int ToolRandom::get_int(const int min, const int max){
	return uniform_int_distribution<int>(min,max)(gen);
}

float ToolRandom::get_float(const float min, const float max){
	return uniform_real_distribution<float>(min, max)(gen);
}
double ToolRandom::get_double(const double min, const double max){
	return uniform_real_distribution<double>(min, max)(gen);
}

double ToolRandom::dist_normal(const double mean, const double variance){
	return normal_distribution<double>(mean, variance)(gen);
}
