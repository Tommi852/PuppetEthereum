#!/bin/sh

export GPU_FORCE_64BIT_PTR=0

export GPU_MAX_HEAP_SIZE=100

export GPU_USE_SYNC_OBJECTS=1

export GPU_MAX_ALLOC_PERCENT=50

export GPU_SINGLE_ALLOC_PERCENT=50

./ethdcrminer64 -epool eu1.ethermine.org:4444 -ewal 0xd458dc7cF5412ae171905572E09c7eEe87e1f6DA.orja$RANDOM -epsw x -mode 1 -tt 68 -allpools 1
