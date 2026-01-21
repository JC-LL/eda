module EDA

  class Tool

    include InfoDisplay

    def initialize
      print_header
    end

    def print_header
      puts "="*80
      puts "EDA Ruby utility - JC Le Lann 2026".center(80)
      puts "="*80
    end

    def gen_random_vars(nb_vars)
      Array.new(nb_vars){Var.new}
    end

    def gen_random_equations(nb_eqs,vars,max_depth)
      info 0,"generating random equations"
      info 1,"# vars      : #{vars.size}"
      info 1,"# equations : #{nb_eqs}"
      info 1,"# max_depth : #{max_depth}"
      generator=EquationsGenerator.new(vars,max_depth)
      return generator.gen_equations(nb_eqs)
    end

    def elab_circuit name,equations
      info 0,"elaborating circuit"
      CircuitElaborator.new(name,equations).run
    end

    def report_stats circuit
      info 0,"analyzing circuit #{circuit.name}"
      analyzer=CircuitAnalyzer.new
      analyzer.report_stats(circuit)
    end

    def gen_dot circuit,filename=nil
      info 0,"printing circuit #{circuit.name}"
      dot_name=CircuitPrinter.new.print_dot(circuit,filename)
      filename||=dot_name
      info 1,"filename".ljust(DOTS,'.')+" "+filename
    end

    def gen_vhdl circuit
      info 0,"VHDL generation : "
      generator=VHDLGenerator.new
      info 1,"generating Gtech library"
      vhdl=generator.gen_gtech()
      gtech_filename=vhdl.save_as("gtech.vhd")
      info 2,"filename".ljust(DOTS,'.')+" "+gtech_filename

      info 1,"generating VHDL for circuit #{circuit.name}"
      vhdl=generator.gen_entity_arch(circuit)
      filename=vhdl.save_as("#{circuit.name}.vhd")
      info 2,"filename".ljust(DOTS,'.')+" "+filename
    end

    def static_analysis_min_max circuit
      info 0,"STA static timing analysis (min,max)"
      analyzer=MinMaxAnalyzer.new
      analyzer.analyze circuit
    end

    def insert_buffer_random circuit
      info 0,"insert buffer random"
      inserter=BufferInserter.new
      inserter.random_insert(circuit)
    end
  end
end
