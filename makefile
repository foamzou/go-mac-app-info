all:
	make swift && make objc && make lib && go build

swift:
	xcrun swiftc -frontend -c -primary-file libs.swift -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/ -module-name libs -emit-module-path libs.swiftmodule -emit-objc-header-path emittedheader.h -parse-as-library -o libsS.o

objc:
	xcrun clang libs.m -o libsC.o -c

lib:
	xcrun swiftc libsC.o libsS.o -emit-library -module-name libs -o libs.a