#!/usr/bin/env bash

mkdir -p downloads
mv *.csv downloads 2>/dev/null
mv *.txt downloads 2>/dev/null
mv *.tsv downloads 2>/dev/null
mv *.zip downloads 2>/dev/null
mv *.wget downloads 2>/dev/null

mkdir -p data