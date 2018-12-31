
vlib work

vlog -timescale 1ns/1ns random.v

vsim random

log {/*}
add wave {/*}

force {resetn} 0 0, 1 10, 0 60, 1 70

force {enable} 0 0, 1 20 -r 40

run 1000ns
