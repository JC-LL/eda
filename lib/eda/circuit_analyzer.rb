DOTS=30

module EDA
  class CircuitAnalyzer
    include InfoDisplay
    def report_stats circuit
      info 1,"inputs".ljust(DOTS,'.')+" #{circuit.inputs.size}"
      info 1,"outputs".ljust(DOTS,'.')+" #{circuit.outputs.size}"
      info 1,"subcomponents".ljust(DOTS,'.')+" #{circuit.components.size}"
      info 1,"average fanout".ljust(DOTS,'.')+" #{circuit.get_average_fanout.round(2)}"
      info 1,"max path (in gates count)".ljust(DOTS,'.')+" #{depth(circuit)}"
      #walk(circuit)
    end

    def depth circuit
      @port_path={} #port -> nb components to get here
      circuit.inputs.each do |input|
        @port_path[input]=0
      end
      critical_length=circuit.outputs.map{|output|depth_rec(output)}.max - 1
    end

    def depth_rec port
      if length=@port_path[port]
        return length
      else
        comp=port.source.component
        max=comp.inputs.map{|input| depth_rec(input)}.max
        return @port_path[port]=1+max
      end
    end

    def walk circuit
      @visited=[]
      circuit.inputs.each do |input|
        fwd_walk_rec(input)
      end
    end

    def fwd_walk_rec port
      port.sinks.each do |sink|
        sink_comp=sink.component
        if @visited.include?(sink_comp)
          return
        else
          @visited << sink_comp
          sink_comp.outputs.each do |output|
            fwd_walk_rec(output)
          end
        end
      end
    end
  end
end
