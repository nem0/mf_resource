#include "mf_resource.h"
#include <stdio.h>


int main()
{
	mf_compile_dir(".", "*", "resources.cpp");
//	auto res = stb_get_resource("in/test.txt");
//	printf(res->value);
//	getchar();
}