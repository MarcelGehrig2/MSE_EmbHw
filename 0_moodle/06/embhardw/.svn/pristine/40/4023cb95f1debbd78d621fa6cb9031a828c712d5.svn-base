#
# basic script to build design under test and testbench
# start modelsim hdl simulator and run do start.do to run script
#

#############################################################
# define alias
#############################################################
alias tb_env {
  echo "\nSET ENVIRONMENT\n"
  quietly set VHDL_SOURCE_DIR "../../src/vhdl/LCD_ctrl"
  quietly set VHDL_TB_DIR "../vhdl"
  vlib work
  echo "SET ENVIRONMENT DONE!\n"
}


alias design {
  echo "\nCOMPILE DESIGN\n"
  eval vcom -work work $VHDL_SOURCE_DIR/DMA_LCD_ctrl.vhd
  echo "COMPILE DESIGN DONE!\n"
}


alias testbench {
  echo "\nCOMPILE TESTBENCH\n"
  eval vcom -work work $VHDL_TB_DIR/avalon_pkg/avalon_pkg.vhd
  eval vcom -work work $VHDL_TB_DIR/lcd_controller_tb.vhd
  echo "\nCOMPILE TESTBENCH DONE!\n"
}


alias run_simulation {
  echo "\nRUN SIMULATION\n"
  vsim -t 1ns -l simulation_logfile.txt work.lcd_controller_tb
  do wave.do
  run 10us
  echo "\nRUN TESTBENCH DONE!\n"

}


#############################################################
# run alias
#############################################################
tb_env
design
testbench
run_simulation

