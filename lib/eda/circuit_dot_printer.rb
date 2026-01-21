module EDA

  class CircuitPrinter

    def print_dot circuit,filename
      dot=Code.new
      dot << "digraph #{name=circuit.name}{"
      dot.indent=2
      dot << "graph [rankdir = LR];"
      dot.newline
      dot << "// ======= ports decls ========"
      circuit.inputs.each do |port|
        #dot << "#{name_last(port)}[shape=cds,xlabel=\"#{port.name}\"]"
        dot << "#{name_last(port)}[shape=cds]"
        dot << "#{port.id}[shape=point]"
        dot << "#{name_last(port)} -> #{port.id}[label=\"#{port}\"]"
      end
      circuit.outputs.each do |port|
        #dot << "#{name_last(port)}[shape=cds,xlabel=\"#{port.name}\"]"
        dot << "#{name_last(port)}[shape=cds]"
      end
      circuit.components.collect{|c| c.outputs}.flatten.each do |port|
        dot << "#{port.id}[shape=point]"
      end
      dot.newline
      dot << "// ======= comps decls ========"
      circuit.components.each do |component|
        comp_name=name_last(component,'::')
        inputs =component.inputs.map {|port| "<#{port.name}>#{port.name}"}.join("|")
        outputs=component.outputs.map{|port| "<#{port.name}>#{port.name}"}.join("|")
        left   ="{#{inputs}}"
        right  ="{#{outputs}}"
        label  ="{#{left}| #{comp_name} |#{right}}"
        color=component.infos[:color] || "cadetblue"
        dot << "#{comp_name}[shape=record; style=\"filled\";fillcolor=#{color}; label=\"#{label}\"]"
        component.outputs.each do |output|
          dot << "#{comp_name}:#{output.name} -> #{output.id}[label=\"w#{output.id}\"]"
        end
      end
      dot.newline
      dot << "// ======= interconnect ========"
      sources=[circuit.inputs,circuit.components.map{|c| c.outputs}].flatten
      sources.each do |source|
        if source.component==circuit # top level
          dot_name=source.id
          source_name=dot_name
        else
          source_comp_name=name_last(source.component,'::')
          source_name=[source_comp_name,source.name].join(":")
        end
        source_name=source.id
        source.sinks.each do |sink|
          sink_comp_name=name_last(sink.component,'::')
          sink_name  = (sink.component==circuit) ? sink.name : [sink_comp_name,sink.name].join(":")
          dot << "#{source_name} -> #{sink_name}"
        end
      end
      dot.indent=0
      dot << "}"
      filename||="#{name}.dot"
      dot.save_as filename
    end

    def name_last thing,separator='.'
      thing.name.to_s.split(separator).last
    end
  end
end
