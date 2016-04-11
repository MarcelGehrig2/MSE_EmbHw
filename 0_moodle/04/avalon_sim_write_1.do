restart

force clk 0 0, 1 10ns -repeat 20ns
force reset 1 0, 0 100ns

force avalon_address xx 0, 00 205ns, xx 225ns, 01 405ns, xx 425ns
force avalon_write_data 16#XX 0, 16#2A 205ns, 16#XX 225ns, 16#CC 405ns, 16#XX 425ns
force avalon_wr 0 0, 1 205ns, 0 225ns, 1 405ns, 0 425ns
force avalon_cs 0 0, 1 208ns, 0 228ns, 1 405ns, 0 425ns
run 600ns
