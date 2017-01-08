#include "mf_resource.h"
#include <stdio.h>


void test1()
{
	mf_compile_dir("in/", "*", "resources.cpp");
	//	auto res = stb_get_resource("in/test.txt");
	//	printf(res->value);
}


void test2()
{
	mf_compile_dir("in2/", "*", "resources.cpp");
	//	auto res = stb_get_resource("in2/test.txt");
	//	printf(res->value);
}


void test3()
{
	mf_resource_compiler compiler = mf_begin_compile("resources.cpp");
	mf_compile(&compiler, "in2/a/", "*");
	mf_compile(&compiler, "in2/b/", "*");
	mf_end_compile(&compiler);
	//	auto res = stb_get_resource("in2/test.txt");
	//	printf(res->value);
}



int main()
{
	test3();
	//	getchar();
}