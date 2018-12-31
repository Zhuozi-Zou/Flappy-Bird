
vlib work

vlog -timescale 1ns/1ns project.v

vsim control

log {/*}
add wave {/*}

force {clk} 0 0, 1 5 -r 10 

force {resetn} 0 0, 1 10

force {paint} 0 0, 1 30, 0 40, 1 335, 0 345

force {counter_draw_pipes} 1 0

force {counter_draw_apples} 1 0

force {counter_draw_bird} 1 0

force {counter_over} 0 0, 1 150, 0 160, 1 305, 0 315

force {over} 0 0, 1 255, 0 290

run 800ns
