#include "DataHolder.h"

using namespace std;

DataHolder::DataHolder(const tp_t window_size, const tp_t start, const tp_t end, const string& fn)
	:window_size(window_size), start_t(start), end_t(end), sts(fn)
{
	_init(sts);
}

DataHolder::DataHolder(const tp_t window_size, const tp_t start, const tp_t end, const SpikeTrains& sts)
	: window_size(window_size), start_t(start), end_t(end), sts(sts)
{
	_init(sts);
}

DataHolder::DataHolder(const tp_t window_size, const tp_t start, const tp_t end, SpikeTrains&& sts)
	: window_size(window_size), start_t(start), end_t(end), sts(sts)
{
	_init(sts);
}

void DataHolder::_init(const SpikeTrains& sts){
	for(const SpikeTrains::SpikeTrain& st : sts.get()){
		cont.push_back(SCV(window_size, start_t, end_t, st));
	}
	cont.shrink_to_fit();
}

double DataHolder::pearson_correlatino(const SCV& first, const SCV& second){
	size_t l = first.get_length();
	int sx1 = 0, sx2 = 0, sy1 = 0, sy2 = 0, xy = 0;
	for(size_t i = 0; i < l; ++i){
		int x = first[i];
		sx1 += x;
		sx2 += x*x;
		int y = first[i];
		sy1 += y;
		sy2 += y*y;
		xy += x*y;
	}
	int up = l*xy - sx1*sy1;
	int down2 = (l*sx2 - sx1*sx1)*(l*sy2 - sy1*sy1);
	return up / sqrt(down2);
}
double DataHolder::pearson_correlatino(const size_t first, const size_t second){
	return pearson_correlatino(cont[first], cont[second]);
}
double DataHolder::pearson_correlatino(const size_t first, const std::vector<size_t>& second){
	std::vector<reference_wrapper<const SCV>> temp;
	for(size_t idx : second)
		temp.push_back(cref(cont[idx]));
	return pearson_correlatino(cont[first], SCV::union_v(temp));
}
