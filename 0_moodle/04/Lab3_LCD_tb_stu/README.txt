This testbench has been designed to be run from Modelsim for testing the LCD slave interface used in the MSE cours Embedded HW & FW.

For using it you can:
- On Modelsim cd (change directory) to this path (the same as the README file).
- run the script sim.do. It will create the work directory, compile the tb and a fake LCD interface, and run simulation.

When doing so you the simulation will display some errors (red arrows on top). Don't be scared the fake LCD interface is inteded to do so.

For testing your LCD interface:
- Open the LCD_tb.vhd file, replace the fake LCD component by your component.
- modify the sim.do script for compiling your component instead of the fake one.
- rerun the script.

Hopefully there will be less or no errors! Good luck!!
