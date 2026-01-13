module EDA

  class CircuitElaborator

    include InfoDisplay

    def initialize name,equations=[]
      @name,@equations=name,equations
      @netlist=Circuit.new(name)
      @expr_circuit_h={} #subexpr sharing !
    end

    def run
      @equations.each do |eqn|
        info 1,"elaborating expression #{eqn.lhs}"
        @netlist << output=Output.new(eqn.lhs)
        port=compile(eqn.rhs)
        port.connect(output)
      end
      return @netlist
    end

    def compile expr
      #puts "compiling #{expr.to_s}" if $verbose
      case var=binary=unary=expr
      when Var
        input=@netlist.inputs.find{|input| input.name.to_s==var.name.to_s}
        unless input
          @netlist << input=Input.new(var)
        end
        return input
      when Unary
        gate=@expr_circuit_h[unary]
        source=compile(unary.expr)
        unless gate
          case unary.op
          when :not
            @netlist << gate=Inv.new
          when :yes
            if $with_buffer==true
              @netlist << gate=Buf.new
            else
              return source
            end
          end
          @expr_circuit_h[unary]=gate #subexpr sharing !
        end
        sink=gate.get_port_named("i")
        source.connect sink
        return gate.get_port_named("f")
      when Binary
        gate=@expr_circuit_h[binary]
        unless gate
          case binary.op
          when :and
            @netlist << gate=And2.new
          when :or
            @netlist << gate=Or2.new
          when :xor
            @netlist << gate=Xor2.new
          when :nand
            @netlist << gate=Nand2.new
          when :nor
            @netlist << gate=Nor2.new
          else
            raise "unknown boolean function '#{binary.op}'"
          end
          @expr_circuit_h[binary]=gate #subexpr sharing !
        end
        sink=gate.get_port_named("i0")
        source=compile(binary.lhs)
        source.connect sink
        sink=gate.get_port_named("i1")
        source=compile(binary.rhs)
        source.connect sink
        return gate.get_port_named("f")
      end
    end
  end
end
