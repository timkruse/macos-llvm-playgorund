#ifndef TEST_H_
#define TEST_H_

class Test {
private:
  int ivar;

public:
  Test();
  ~Test();

  void add(int);
  int getivar();
};

#endif