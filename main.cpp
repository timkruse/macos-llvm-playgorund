#include <iostream>
#include "test.h"

int main() {
	using namespace std;

	typedef union bitfields{
		uint16_t u16;
		struct nibbles{
			unsigned char ll : 4;
			unsigned char lh : 4;
			unsigned char hl : 4;
			unsigned char hh : 4;
		}nibble;
	}testbits;

	Test t;
	cout << t.getivar() << endl;
	t.add(2);
	cout << t.getivar() << endl;
	
	testbits tb;
	tb.u16 = 0;
	tb.nibble.hh = 0xf;
	printf("%04x\n", tb.u16);

	cout << "hallo welt" << endl;

	return 0;
}