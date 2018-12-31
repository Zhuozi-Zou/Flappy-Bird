
vlib work

vlog -timescale 1ns/1ns project.v

vsim game_over

log {/*}
add wave {/*}

# 58
force {y_bird} 000111010 0

force {x_pipe1} 001010000 0

force {x_pipe2} 001101110 0

force {x_pipe3} 010001100 0

force {x_pipe4} 001000110 0, 001000101 20,  001000100 30, 011110000 60

# 80
force {y_pipe1} 001010000 0

# 70
force {y_pipe2} 001000110 0

# 25
force {y_pipe3} 000011001 0

# 60
force {y_pipe4} 000111100 0

run 100ns
