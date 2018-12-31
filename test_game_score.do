
vlib work

vlog -timescale 1ns/1ns game_score.v

vsim game_score

log {/*}
add wave {/*}

force {clk} 0 0, 1 5 -r 10 

force {resetn} 0 0, 1 10

force {eat1} 0 0, 1 25, 0 75, 1 115, 0 165

force {eat2} 0 0, 1 45, 0 95, 1 135, 0 185

force {eat3} 0 0, 1 65, 0 105, 1 155, 0 205

force {eat4} 0 0, 1 85, 0 125, 1 175, 0 225

run 400ns
