#!/usr/bin/env bash
xelatex -8bit -output-directory=$1 -halt-on-error --enable-write18 --recorder $2
