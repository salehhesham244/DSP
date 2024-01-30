create_project project_DSP48A1 D:/Courses/K.W/Projetcs/Project\ 1 -part xc7a35ticpg236-1L -force

add_files DSP48A1.v A

synth_design -rtl -top DSP48A1 > elab.log

write_schematic elaborated_schematic.pdf -format pdf -force 

launch_runs synth_1 > synth.log

wait_on_run synth_1
open_run synth_1

write_schematic synthesized_schematic.pdf -format pdf -force 

write_verilog -force DSP48A1.v

launch_runs impl_1 -to_step write_bitstream 

wait_on_run impl_1
open_run impl_1

open_hw

connect_hw_server