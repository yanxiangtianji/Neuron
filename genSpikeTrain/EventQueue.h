#pragma once
#include <map>

template<class T_TIME, class T_MSG>
class EventQueue
{
private:
	typedef std::multimap<T_TIME, T_MSG> cont_t;
	cont_t cont;

public:

//	void push(typename cont_t::value_type::first_type& tp, const typename cont_t::value_type::second_type& nid){
	void push(const T_TIME& tp, const T_MSG& nid){ cont.emplace(tp, nid); }
	void push(cont_t::value_type& p){ push(p.first, p.second); }

	typename cont_t::value_type get(){ return *cont.begin(); }
	void pop();
	auto get_n_pop()->decltype(get()){ auto t = get(); pop(); return t; }

	bool empty() const { return cont.empty(); }
	size_t size() const { return cont.size(); }
};

template<class T1, class T2>
void EventQueue<T1,T2>::pop(){
	if(!cont.empty())
		cont.erase(cont.begin());
}

