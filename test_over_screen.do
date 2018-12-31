
vlib work

vlog -timescale 1ns/1ns project.v

vsim over_screen

log {/*}
add wave {/*}

force {clk} 0 0, 1 5 -r 10 

force {resetn} 0 0, 1 10

force {enable} 1 0, 0 1805

run 3500ns
