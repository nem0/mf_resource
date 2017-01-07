local ide_dir = iif(_ACTION == nil, "vs2015", _ACTION)
if "linux-gcc" == _OPTIONS["gcc"] then
	ide_dir = "gcc"
elseif "linux-gcc-5" == _OPTIONS["gcc"] then
	ide_dir = "gcc5"
elseif "linux-clang" == _OPTIONS["gcc"] then
	ide_dir = "clang"
end

local LOCATION = "tmp/" .. ide_dir
local BINARY_DIR = LOCATION .. "/bin/"

newoption {
		trigger = "gcc",
		value = "GCC",
		description = "Choose GCC flavor",
		allowed = {
			{ "asmjs",          	"Emscripten/asm.js"       	 		},
			{ "android-x86",    	"Android - x86"            	 		},
			{ "linux-gcc", 			"Linux (GCC compiler)" 				},
			{ "linux-gcc-5", 		"Linux (GCC-5 compiler)"			},
			{ "linux-clang", 		"Linux (Clang compiler)"			}
		}
	}
	
	
function defaultConfigurations()
	configuration "Debug"
		targetdir(BINARY_DIR .. "Debug")
		defines { "DEBUG", "_DEBUG" }
		flags { "Symbols", "WinMain" }

	configuration "Release"
		targetdir(BINARY_DIR .. "Release")
		defines { "NDEBUG" }
		flags { "Optimize", "WinMain" }

	configuration "RelWithDebInfo"
		targetdir(BINARY_DIR .. "RelWithDebInfo")
		defines { "NDEBUG" }
		flags { "Symbols", "Optimize", "WinMain" }

	configuration "linux"
		buildoptions { "-std=c++14" }
		links { "pthread" }

	configuration { "asmjs" }
		buildoptions { "-std=c++14" }
end


solution "stb_resource"
	if _ACTION == "gmake" then
		configuration { "android-*" }
			flags {
				"NoImportLib",
			}
			includedirs {
				"$(ANDROID_NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/4.9/include",
				"$(ANDROID_NDK_ROOT)/sources/android/native_app_glue",
			}
			linkoptions {
				"-nostdlib",
				"-static-libgcc",
			}
			links {
				"c",
				"dl",
				"m",
				"android",
				"log",
				"gnustl_static",
				"gcc",
			}
			buildoptions {
				"-fPIC",
				"-no-canonical-prefixes",
				"-Wa,--noexecstack",
				"-fstack-protector",
				"-ffunction-sections",
				"-Wno-psabi",
				"-Wunused-value",
				"-Wundef",
			}
			buildoptions_cpp {
				"-std=c++14",
			}
			linkoptions {
				"-no-canonical-prefixes",
				"-Wl,--no-undefined",
				"-Wl,-z,noexecstack",
				"-Wl,-z,relro",
				"-Wl,-z,now",
			}
		
		configuration { "android-x86" }
			androidPlatform = "android-24"
			libdirs {
				path.join(_libDir, "lib/android-x86"),
				"$(ANDROID_NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/4.9/libs/x86",
			}
			includedirs {
				"$(ANDROID_NDK_ROOT)/sources/cxx-stl/gnu-libstdc++/4.9/libs/x86/include",
			}
			buildoptions {
				"--sysroot=" .. path.join("$(ANDROID_NDK_ROOT)/platforms", androidPlatform, "arch-x86"),
				"-march=i686",
				"-mtune=atom",
				"-mstackrealign",
				"-msse3",
				"-mfpmath=sse",
				"-Wunused-value",
				"-Wundef",
			}
			linkoptions {
				"--sysroot=" .. path.join("$(ANDROID_NDK_ROOT)/platforms", androidPlatform, "arch-x86"),
				path.join("$(ANDROID_NDK_ROOT)/platforms", androidPlatform, "arch-x86/usr/lib/crtbegin_so.o"),
				path.join("$(ANDROID_NDK_ROOT)/platforms", androidPlatform, "arch-x86/usr/lib/crtend_so.o"),
			}
	
		configuration {}	
	
		if "asmjs" == _OPTIONS["gcc"] then
			if not os.getenv("EMSCRIPTEN") then
				print("Set EMSCRIPTEN enviroment variable.")
			end
			premake.gcc.cc   = "\"$(EMSCRIPTEN)/emcc\""
			premake.gcc.cxx  = "\"$(EMSCRIPTEN)/em++\""
			premake.gcc.ar   = "\"$(EMSCRIPTEN)/emar\""
			_G["premake"].gcc.llvm = true
			premake.gcc.llvm = true
			LOCATION = "tmp/emscripten_gmake"
		
		elseif "android-x86" == _OPTIONS["gcc"] then
			if not os.getenv("ANDROID_NDK_X86") or not os.getenv("ANDROID_NDK_ROOT") then
				print("Set ANDROID_NDK_X86 and ANDROID_NDK_ROOT envrionment variables.")
			end

			premake.gcc.cc  = "\"$(ANDROID_NDK_X86)/bin/i686-linux-android-gcc\""
			premake.gcc.cxx = "\"$(ANDROID_NDK_X86)/bin/i686-linux-android-g++\""
			premake.gcc.ar  = "\"$(ANDROID_NDK_X86)/bin/i686-linux-android-ar\""
			LOCATION = "tmp/android-x86_gmake"
		
		elseif "linux-gcc" == _OPTIONS["gcc"] then
			LOCATION = "tmp/gcc"

		elseif "linux-gcc-5" == _OPTIONS["gcc"] then
			premake.gcc.cc  = "gcc-5"
			premake.gcc.cxx = "g++-5"
			premake.gcc.ar  = "ar"
			LOCATION = "tmp/gcc5"
			
		elseif "linux-clang" == _OPTIONS["gcc"] then
			premake.gcc.cc  = "clang"
			premake.gcc.cxx = "clang++"
			premake.gcc.ar  = "ar"
			LOCATION = "tmp/clang"

		end
		BINARY_DIR = LOCATION .. "/bin/"
	end
	
	configuration { "linux-*" }
		buildoptions {
			"-fPIC",
			"-no-canonical-prefixes",
			"-Wa,--noexecstack",
			"-fstack-protector",
			"-ffunction-sections",
			"-Wno-psabi",
			"-Wunused-value",
			"-Wundef",
			"-msse2",
		}
		linkoptions {
			"-Wl,--gc-sections",
		}
	
	configuration { "linux-*", "x32" }
		buildoptions {
			"-m32",
		}

	configuration { "linux-*", "x64" }
		buildoptions {
			"-m64",
		}

	configuration {}
	
	configurations { "Debug", "Release", "RelWithDebInfo" }
	platforms { "x64" }
	flags { 
		"FatalWarnings", 
		"NoPCH", 
		"NoExceptions", 
		"NoRTTI", 
		"NoEditAndContinue"
	}
	includedirs {"../" }
	location(LOCATION)
	language "C++"
	startproject "studio"

	configuration { "vs*" }
		defines { 
			"_HAS_EXCEPTIONS=0",
			"_CRT_SECURE_NO_WARNINGS"
		}


project "stb_resource"
	kind "ConsoleApp"

	debugdir ("../test")
	
	files {
			"../**.cpp",
			"../**.h",
			"genie.lua"
	}

	defaultConfigurations()
