#!/bin/bash
. $(dirname $0)/common.inc

mkdir -p $t/libs/SomeFramework.framework/

cat > $t/libs/SomeFramework.framework/SomeFramework.tbd <<EOF
--- !tapi-tbd
tbd-version:     4
targets:         [ x86_64-macos, arm64-macos ]
uuids:
  - target:          x86_64-macos
    value:           00000000-0000-0000-0000-000000000000
  - target:          arm64-macos
    value:           00000000-0000-0000-0000-000000000000
install-name:    '/usr/frameworks/SomeFramework.framework/SomeFramework'
current-version: 0000
compatibility-version: 150
reexported-libraries:
  - targets:         [ x86_64-macos, arm64-macos ]
    libraries:       [ ]
exports:
  - targets:         [ x86_64-macos, arm64-macos ]
    symbols:         [ _foo ]
    weak-symbols:    [ _bar ]
...
EOF

cat <<EOF | $CC -o $t/a.o -c -xc -
extern void foo();
extern void bar() __attribute__((weak_import));

int main() {
  foo();
  if (bar)
    bar();
}
EOF

$CC --ld-path=./ld64 -o $t/exe $t/a.o -F$t/libs/ -Wl,-framework,SomeFramework

otool -L $t/exe | grep -q '/usr/frameworks/SomeFramework.framework/SomeFramework'
