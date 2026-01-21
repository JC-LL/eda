module EDA

  class CircuitSxpParser

    include InfoDisplay

    def parse code
      ary=SXP.read(code)
      @ref={} #id -> port
      case ary.first
      when :circuit
        circuit=parse_circuit(ary)
      else
        raise "ERROR : expecting 'circuit'"
      end
      info 1,"parsed successfully"
      return circuit
    end

    def parse_circuit ary
      ary.shift # circuit
      name=ary.shift
      circuit=Circuit.new(name.to_s+"_rr")
      while ary.any?
        #step "#{ary.first}"
        case type=type_of(ary.first)
        when :input
          circuit << parse_input(ary.shift)
        when :output
          circuit << parse_output(ary.shift)
        when :instance
          circuit << parse_instance(ary.shift)
        when :connect
          parse_interconnect(ary.shift)
        else
          raise "ERROR : #{type} encountered."
        end
      end
      circuit
    end

    def type_of ary
      ary.first
    end

    def parse_type ary
      ary.shift
      ary.first
    end

    def parse_input ary
      ary.shift #input
      name=ary.shift
      id=parse_id(ary.first)
      ret=Input.new(name)
      ret.id=id
      @ref[id]=ret
      ret
    end

    def parse_output ary
      ary.shift #output
      name=ary.shift
      id=parse_id(ary.first)
      ret=Output.new(name)
      ret.id=id
      @ref[id]=ret
      ret
    end

    def parse_id ary
      ary.shift #id
      ary.first
    end

    def parse_instance ary
      ary.shift # instance
      iname=ary.shift
      type=parse_type(ary.shift)
      case type
      when :buf
        instance=Buf.new(iname)
      when :inv
        instance=Inv.new(iname)
      when :and2
        instance=And2.new(iname)
      when :or2
        instance=Or2.new(iname)
      when :xor2
        instance=Xor2.new(iname)
      when :nand2
        instance=Nand2.new(iname)
      when :nor2
        instance=Nor2.new(iname)
      else
        raise "unknown instance '#{type}'"
      end
      # ports read in instance are just here for their ID.
      while ary.any?
        case type=type_of(ary.first)
        when :input
          port=parse_input(ary.shift)
        when :output
          port=parse_output(ary.shift)
        else
          raise "ERROR : #{type} encountered."
        end
        #============================================================
        # WARNING ! Need to attribute correct id to instance port !
        iport=instance.get_port_named(port.name)
        iport.id=port.id
        @ref[iport.id]=iport # dont forget this one !
      end
      instance
    end

    def parse_interconnect ary
      ary.shift #interconnect
      source=ary.shift
      port_source=@ref[source]
      sinks=ary
      sinks.each do |sink|
        port_sink=@ref[sink]
        port_source.connect(port_sink)
      end
    end
  end
end
