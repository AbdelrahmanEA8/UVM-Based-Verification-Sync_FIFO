vlib work
vlog -f file.txt +define+SIM +cover
vsim -voptargs=+acc work.TOP -cover +UVM_VERBOSITY=UVM_MEDIUM


add wave -position 1 -color white sim:/TOP/fifoif/clk 
add wave -position 2 -radix hexadecimal sim:/TOP/fifoif/rst_n 
add wave -position 3 -radix hexadecimal sim:/TOP/fifoif/data_in 
add wave -position 4 -color Orange -radix hexadecimal sim:/TOP/fifoif/rd_en 
add wave -position 5 -color Orange -radix hexadecimal sim:/TOP/fifoif/wr_en 
add wave -position 6 -color yellow -radix hexadecimal sim:/TOP/fifoif/data_out 
add wave -position 7 -color Orchid -radix hexadecimal sim:/TOP/fifoif/data_out_ref 
add wave -position 8 -color yellow -radix hexadecimal sim:/TOP/fifoif/wr_ack
add wave -position 9 -color Orchid -radix hexadecimal sim:/TOP/fifoif/wr_ack_ref
add wave -position 10 -color yellow -radix hexadecimal sim:/TOP/fifoif/overflow 
add wave -position 11 -color Orchid -radix hexadecimal sim:/TOP/fifoif/overflow_ref 
add wave -position 12 -color yellow -radix hexadecimal sim:/TOP/fifoif/underflow
add wave -position 13 -color Orchid -radix hexadecimal sim:/TOP/fifoif/underflow_ref
add wave -position 14 -color yellow -radix hexadecimal sim:/TOP/fifoif/empty
add wave -position 15 -color Orchid -radix hexadecimal sim:/TOP/fifoif/empty_ref
add wave -position 16 -color yellow -radix hexadecimal sim:/TOP/fifoif/almostempty
add wave -position 17 -color Orchid -radix hexadecimal sim:/TOP/fifoif/almostempty_ref
add wave -position 18 -color yellow -radix hexadecimal sim:/TOP/fifoif/full
add wave -position 19 -color Orchid -radix hexadecimal sim:/TOP/fifoif/full_ref
add wave -position 20 -color yellow -radix hexadecimal sim:/TOP/fifoif/almostfull
add wave -position 21 -color Orchid -radix hexadecimal sim:/TOP/fifoif/almostfull_ref
add wave -position 22 -radix unsigned sim:/Shared_Pkg::error_count 
add wave -position 23 -radix unsigned sim:/Shared_Pkg::correct_count
add wave -position insertpoint  \
sim:/TOP/DUT/count \

coverage save TOP.ucdb -onexit

run -all
# Save coverage first (if not already done)
#coverage save -assert -directive -codeAll TOP.ucdb

# Generate reports
vcover report -html -details -assert -directive -codeAll -output coverage_report.html TOP.ucdb
#vcover report -assert -directive -codeAll TOP.ucdb > coverage_summary.txt
coverage report -output coverage_summary.txt -srcfile=TOP.sv -detail -all -dump -annotate -option -assert -directive -cvg -codeAll
coverage report -detail -cvg -directive -comments -output fcover_report.txt {}