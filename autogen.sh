#!/bin/sh

makefoo_prefix=`pkg-config --variable=prefix makefoo`

aclocal -I "${makefoo_prefix}/share/aclocal"
autoconf

