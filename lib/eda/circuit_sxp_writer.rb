module EDA
  class CircuitSxpWriter
    include InfoDisplay

    def write circuit
      code=Code.new
      code << "(circuit #{circuit.name}"
      code.indent=2
      code << gen_io(circuit)
      code.newline
      code << gen_components(circuit)
      code.newline
      code << gen_interconnects(circuit)
      code.indent=0
      code << ")"
      code
    end

    def gen_io circuit
      code=Code.new
      circuit.inputs.each do |input|
        code << "(input #{input.name} (id #{input.id}))"
      end
      circuit.outputs.each do |output|
        code << "(output #{output.name} (id #{output.id}))"
      end
      code
    end

    def gen_components circuit
      code=Code.new
      circuit.components.each do |comp|
        splitted_name=comp.name.downcase.split('::')
        instance_name=splitted_name.last
        type_name=instance_name.split('_').first
        code << "(instance #{instance_name}"
        code.indent=2
        code << "(type #{type_name})"
        code << gen_io(comp)
        code.indent=0
        code << ")"
      end
      code
    end

    def gen_interconnects circuit
      sources=[]
      sources << circuit.inputs
      sources << circuit.components.collect{|c| c.outputs}
      sources.flatten!
      code=Code.new
      sources.each{|source| code << gen_interconnect(source)}
      code
    end

    def gen_interconnect source
      code=Code.new
      sinks_id=source.sinks.collect{|sink| sink.id}.map(&:to_s).join(" ")
      code << "(connect #{source.id} #{sinks_id})"
      code
    end

  end
end
