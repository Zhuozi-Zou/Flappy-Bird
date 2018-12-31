
vlib work

vlog -timescale 1ns/1ns project.v

vsim combination

log {/*}
add wave {/*}

force {CLOCK_50} 0 0, 1 5 -r 10

# resetn
# force {KEY[0]} 0 0, 1 10

# paint
force {KEY[1]} 1 0, 0 20, 1 30

run 2000ns
