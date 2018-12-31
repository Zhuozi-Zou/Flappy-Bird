
vlib work

vlog -timescale 1ns/1ns project.v

vsim datapath

log {/*}
add wave {/*}
add wave {/datapath/ycd0/*}

force {enable} 0 0

force {enable_bird} 0 0, 1 205, 0 215

force {updown} 0 0, 1 185, 0 195

force {en_bird} 0 0, 1 15, 0 175, 1 335

force {en_apples} 0 0, 1 175, 0 335

force {en_pipes} 0 0
#, 1 335, 0 1585

force {clk} 0 0, 1 5 -r 10 

force {color_in} 001 0, 100 175, 001 335
#, 010 335, 000 1585

force {resetn} 0 0, 1 10

run 600ns
