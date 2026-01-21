module EDA
  class BufferInserter
    include InfoDisplay
    # pick a wire source.
    # disconnect one of its sink. and connect to new buffer.
    def random_insert circuit,delay=1
      info 1,"random insertion"
      candidates_wires=get_candidates(circuit)
      target_source=candidates_wires.sample
      target_sink=target_source.sinks.sample
      circuit << buffer=create_buffer(circuit)
      buffer.infos[:delay]=delay
      buffer.infos[:color]="red" # for visualization
      buffer_input=buffer.get_port_named(:i)
      buffer_output=buffer.get_port_named(:f)
      target_source.sinks.delete(target_sink)
      target_source.connect(buffer_input)
      buffer_output.connect(target_sink)
    end

    def get_candidates circuit
      info 2,"listing candidates"
      ret=[]
      ret << circuit.inputs
      ret << circuit.components.collect{|comp| comp.outputs}
      ret.flatten
    end

    def create_buffer circuit
      info 2,"creating buffer"
      EDA::Buf.new
    end
  end
end
