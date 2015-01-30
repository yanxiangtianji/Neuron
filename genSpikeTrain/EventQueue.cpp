#include "EventQueue.h"

void EventQueue::push(cont_t::value_type::first_type& tp, cont_t::value_type::second_type& nid){
	cont.emplace(tp, nid);
}

void EventQueue::pop(){ 
	if(!cont.empty()) 
		cont.erase(cont.begin()); 
}

EventQueue::cont_t::value_type EventQueue::get(){
	return *cont.begin();
}
