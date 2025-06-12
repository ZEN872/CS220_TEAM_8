# CS220_TEAM_8

Code taken from this repo: https://github.com/openhwgroup/cv32e40p  

## How to run Simulation:

- Go to the sim directory 
- Find the directory of your folder and then use the command: export DESIGN_RTL_DIR= "Your RTL directory"

**Example:**  export DESIGN_RTL_DIR=/home/cegrad/imaga008/CS220_TEAM_8/rtl/

-   Find the directory of your "cv32e40p_fpu_manifest.flist"

**Example:** /home/cegrad/imaga008/CS220_TEAM_8/cv32e40p_fpu_manifest.flist 

- Then run this command to launch the sim: vcs -sverilog "Name of top file".sv -f  "directory cv32e40p_fpu_manifest.flist" -full64 -P /usr/local/synopsys/verdi/V-2023.12-SP2-5/share/PLI/VCS/LINUX64/novas.tab /usr/local/synopsys/verdi/V-2023.12-SP2-5/share/PLI/VCS/LINUX64/pli.a
  
**EXAMPLE:** vcs -sverilog cv32e40p_top_tb.sv -f /home/cegrad/imaga008/CS220_TEAM_8/cv32e40p_fpu_manifest.flist -full64 -P /usr/local/synopsys/verdi/V-2023.12-SP2-5/share/PLI/VCS/LINUX64/novas.tab /usr/local/synopsys/verdi/V-2023.12-SP2-5/share/PLI/VCS/LINUX64/pli.a

- Then run the command: **./sim**
- Then you will have to export the .vcd file generated to your local machine. **The Reason we have to move it to our local machine is that Verdi can not read the file, and the Bender server does not have gtkwave.**
- Then run the following command on your local machine: **gtkwave "name of file".vcd**
  
**WARNING: If you do not have GTKwave installed, this is the command to install on your local machine:** 

- sudo apt install gtkwave


## How to run Synthesis : 
- Go to the syn directory 
- Edit the syn.tcl to match your home directory. **( You will be editing the line that starts with **SET HOME** [then some directoy)] )** 

**EXAMPLE:** set HOME "/home/cegrad/imaga008/CS220_CORE_WK_8"

- Enter the command: **dc_shell**
- Then, once in the dc shell enter the command: **source syn.tcl**

**WARNING: IF you get warnings that stop the syn, then just press the ENTER key repeatedly until the warning goes away**

## How to run Primetime:

### To run the prime time:
- You would have already run the simulation script **(Generate a .vcd file)**
- You would have already run the synthesis script file **(Generate a synthesis.v file)**
  
- Once these files are made, you have to enter the ptpx directory
- Then enter the pt shell by using the command : *pt_shell*
- Then enter the command: *source "name_of_primetime_script.tcl"*

**Example:** *source baseline_primetime.tcl*

- Then exit the pt shell; if successful, the prime time reports would have been generated. 
  
