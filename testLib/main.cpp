#include <iostream>
#include <string>
#include "test_eval.h"
#include "test_powerlaw.h"

using namespace std;

int main(){
//	test_pld();
//	test_rnd_speed(10);
	test_degree_pl(10, 2.5);
	test_degree_pl(50,2.5);
	return 0;
}

