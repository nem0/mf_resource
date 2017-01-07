#include "stb_resource.h"
#include <stdio.h>


int main()
{
	stb_compile_dir("in/", "*", "resources.cpp");
	auto res = stb_get_resource("in/test.txt");
	printf(res->value);
	getchar();
}