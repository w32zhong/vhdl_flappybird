#!/bin/bash
fun () {
	./img2vhdl.py img/${1}.png > ${1}.txt
	unix2dos ${1}.txt
}

fun 0
fun 1
fun 2
