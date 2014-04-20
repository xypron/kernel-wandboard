#!/bin/sh
at now -f make-dpkg.job
atq
multitail make.log
