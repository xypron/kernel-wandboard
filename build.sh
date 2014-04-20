#!/bin/sh
at now -f make.job
atq
multitail make.log
