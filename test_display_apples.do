
vlib work

vlog -timescale 1ns/1ns project.v

vsim display_apples

log {/*}
add wave {/*}

force {en_apples} 0 0, 1 20

# 58
force {y_bird} 000111010 0

force {x_apple1} 001010000 0

force {x_apple2} 001101110 0

force {x_apple3} 010001100 0

force {x_apple4} 000110011 0
#, 000110010 20,  000110001 30, 000110000 40, 010101011 60, 010101010 120, 010101001 130  

# 80
force {y_apple1} 001010000 0

# 70
force {y_apple2} 001000110 0

# 25
force {y_apple3} 000011001 0

# 60
force {y_apple4} 000111100 0

force {apple2} 0 0, 1 25

force {apple3} 0 0, 1 45

force {apple4} 0 0, 1 65
#, 0 90

force {resetn} 0 0, 1 10

run 200ns
