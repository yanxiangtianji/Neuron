#include <iostream>
#include <fstream>
#include "EventQueue.h"
#include "def.h"

using namespace std;

void test_eq(){
	EventQueue<int,int> eq;
	eq.push(3, 10);
	eq.push(4, 60);
	eq.push(4, 61);
	eq.push(6, 60);
	while(!eq.empty()){
		auto p = eq.get_n_pop();
		cout << p.first << ' ' << p.second << endl;
	}
}

int main(){
	test_eq();
	return 0;
}
