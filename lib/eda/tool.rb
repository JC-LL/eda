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

    def print_dot circuit
      info 0,"printing circuit #{circuit.name}"
      dot_name=CircuitPrinter.new.print_dot(circuit)
      info 1,"filename".ljust(DOTS,'.')+" "+dot_name

    end
  end
end
