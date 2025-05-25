# CS220_TEAM_8

## How to run Sim:

- Go to the sim directory 
- Find the directory of your folder and then use the command: DESIGN_RTL_DIR= "Your RTL directory"

**Example:**  DESIGN_RTL_DIR=/home/cegrad/imaga008/CS220_TEAM_8/rtl/

-   Find the directory of your "cv32e40p_fpu_manifest.flist"

**Example:** /home/cegrad/imaga008/CS220_TEAM_8/cv32e40p_fpu_manifest.flist 

- Then run this command to launch the sim: vcs -sverilog "Name of top file".sv -f  "directory cv32e40p_fpu_manifest.flist" -full64 -P /usr/local/synopsys/verdi/V-2023.12-SP2-5/share/PLI/VCS/LINUX64/novas.tab /usr/local/synopsys/verdi/V-2023.12-SP2-5/share/PLI/VCS/LINUX64/pli.a
- 
**EXAMPLE:** vcs -sverilog cv32e40p_top_tb.sv -f /home/cegrad/imaga008/CS220_TEAM_8/cv32e40p_fpu_manifest.flist -full64 -P /usr/local/synopsys/verdi/V-2023.12-SP2-5/share/PLI/VCS/LINUX64/novas.tab /usr/local/synopsys/verdi/V-2023.12-SP2-5/share/PLI/VCS/LINUX64/pli.a

## How to run syn: 
-Go to the syn directory 
-Edit the syn.tcl to match your home directory. **(**You will be editing the line that starts with **SET HOME** [then some directoy)] **)** 

**EXAMPLE:** set HOME "/home/cegrad/imaga008/CS220_CORE_WK_8"

- Enter dc_shell
- Enter source syn.tcl
**IF you get warnings that stop the syn, then just press the ENTER key repeatly until the warning go away**
  
