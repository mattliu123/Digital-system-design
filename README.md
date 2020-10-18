Src/
    Baseline/
        /rtl
            CHIP.v	        Top module of this design, including RISCV_Pipeline, I_cache, and D_cache
        /syn
            CHIP_syn.v      
            CHIP_syn.ddc
            CHIP_syn.sdf

            To compile : ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+hasHazard +define+SDF +access+r
    
    Extension/
        
        /BrPred	
            /rtl
                CHIP.v	    Top module of this design, including RISCV_Pipeline, I_cache, and D_cache
            /syn
                CHIP_syn.v      
                CHIP_syn.ddc
                CHIP_syn.sdf

                To compile : ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+BrPred +define+SDF +access+r
        
        /Compression
            /rtl
                CHIP.v	    Top module of this design, including RISCV_Pipeline, I_cache, and D_cache
            /syn
                CHIP_syn.v      
                CHIP_syn.ddc
                CHIP_syn.sdf

                To compile : ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+compression +define+SDF +access+r
        
        /L2Cache
            /rtl
                CHIP.v	    Top module of this design, including RISCV_Pipeline, I_cache, and D_cache
            /syn
                CHIP_syn.v      
                CHIP_syn.ddc
                CHIP_syn.sdf

                To compile : ncverilog Final_tb.v CHIP_syn.v slow_memory.v tsmc13.v +define+hasHazard +define+SDF +access+r

DSD_Final_Project_Scores_RISCV.pdf      SYN data
Presentation.pptx                       PPT of presentation
Report.pdf                              Report with introduction and analysis