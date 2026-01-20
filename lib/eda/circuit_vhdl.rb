module EDA

  class VHDLGenerator

    def gen_entity_arch circuit
      code=Code.new
      code << header()
      code << ieee()
      code.newline
      code << gtech_lib()
      code.newline
      code << gen_entity(circuit)
      code.newline
      code << gen_arch(circuit)
      code
    end

    def line
      "-- "+"-"*80
    end

    def header
      code=Code.new
      code << line()
      code << "-- "+"generated automatically by EDA Ruby tools - JC Le Lann 2026".center(80)
      code << line()
      code
    end

    def ieee
      code=Code.new
      code << "library ieee;"
      code << "use ieee.std_logic_1164.all;"
      code << "use ieee.numeric_std.all;"
      code
    end

    def gtech_lib
      "library gtech_lib;"
    end

    def gen_entity circuit
      code=Code.new
      code << "entity #{circuit.name.to_s} is"
      code.indent=2
      code << "port("
      code.indent=4
      circuit.inputs.each do |input|
        code << "#{input.name.to_s} : in std_logic;"
      end
      circuit.outputs.each do |output|
        code << "#{output.name.to_s} : out std_logic;"
      end
      code.indent=2
      code << ");"
      code.indent=0
      code << "end entity;"
      code
    end

    def gen_arch circuit
      code=Code.new
      code << "architecture netlist of #{circuit.name.to_s} is"
      code.indent=2
      circuit.inputs.each do |input|
        code << "signal w#{input.id} : std_logic;"
      end
      circuit.components.collect{|comp| comp.outputs}.flatten.each do |port|
        code << "signal w#{port.id} : std_logic;"
      end
      code.indent=0
      code << "begin"
      code.indent=2
      circuit.inputs.each do |input|
        code << "w#{input.id} <= #{input.name};"
      end
      circuit.components.each do |comp|
        code << gen_entity_instanciation(comp)
      end
      circuit.outputs.each do |output|
        code << "#{output.name} <= w#{output.source.id};"
      end
      code.indent=0
      code << "end architecture;"
      code
    end

    def gen_entity_instanciation comp
      code=Code.new
      instance_name=comp.name.split('::').last.downcase
      code << "#{instance_name} : entity gtech_lib.#{gtech_name(comp)}(equation)"
      code.indent=2
      code << "port map("
      code.indent=4
      comp.inputs.each do |input|
        code << "#{input.name} => w#{input.source.id},"
      end
      comp.outputs.each do |output|
        code << "#{output.name} => w#{output.id},"
      end
      code.indent=2
      code << ");"
      code.indent=0
      code
    end

    #================================================
    def gen_gtech
      code=Code.new
      code << header()
      code << "-- Types of gates handled here : "
      GTECH.each do |klass|
        code << "-- #{klass.to_s.split('::').last}"
      end
      code << "-- "+"-"*80
      GTECH.each do |klass|
        gate=klass.new
        code << gen_entity_arch_gtech(gate)
        code.newline
      end
      code
    end

    def gen_entity_arch_gtech circuit
      code=Code.new
      code << ieee()
      code.newline
      code << gen_entity_gtech(circuit)
      code.newline
      code << gen_arch_gtech(circuit)
      code
    end

    def gen_entity_gtech circuit
      entity_name=gtech_name(circuit)
      code=Code.new
      code << "entity #{entity_name} is"
      code.indent=2
      code << "port("
      code.indent=4
      circuit.inputs.each do |input|
        code << "#{input.name.to_s.downcase} : in std_logic;"
      end
      circuit.outputs.each do |output|
        code << "#{output.name.to_s.downcase} : out std_logic;"
      end
      code.indent=2
      code << ");"
      code.indent=0
      code << "end entity;"
      code
    end

    def gen_arch_gtech circuit
      entity_name=gtech_name(circuit)
      code=Code.new
      code << "architecture equation of #{entity_name} is"
      code << "begin"
      code.indent=2
      case circuit
      when EDA::Buf
        code << "f <= i;"
      when EDA::Inv
        code << "f <= not(i);"
      when EDA::And2
        code << "f <= i0 and i1;"
      when EDA::Nand2
        code << "f <= i0 and i1;"
      when EDA::Or2
        code << "f <= i0 or i1;"
      when EDA::Nor2
        code << "f <= i0 nor i1;"
      when EDA::Xor2
        code << "f <= i0 xor i1;"
      else
        raise "circuit class #{circuit.class} not handled in gtech generation."
      end
      case entity_name
      when "Inv"
        code << "f <= not(i);"
      when "And2"
        code << "f <= i0 and i1;"
      else
      end
      code.indent=0
      code << "end architecture;"
      code
    end

    def gtech_name circuit
      name_wo_eda=circuit.name.to_s.split("::").last
      name_wo_eda.split('_').first.downcase
    end
    #===========================================================
  end
end
