#include "test.h"

Test::Test() : ivar(0) {}

Test::~Test() {}

void Test::add(int val){
	this->ivar += val;
}

int Test::getivar() {
	return this->ivar;
}