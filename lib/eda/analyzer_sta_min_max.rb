module EDA

  class MinMaxSTA
    include InfoDisplay

    def analyze circuit
      @comp_delay={}
      # assign random integer intrinsic delays to components if not provided.
      circuit.components.each do |comp|
        comp.infos[:delay]||=1+rand(10)
      end
      @min_max={}
      # starts with time min max times [0;0]
      circuit.inputs.each do |input|
        @min_max[input]=[0,0]
        propagate(input)
      end
      @fifo=[circuit.components].flatten
      run()
    end

    def run
      while @fifo.any?
        comp=@fifo.shift
        try_compute(comp)
      end
      @min_max.each do |port,minmax|
        puts "port #{port.component.name}.#{port.name} -> #{minmax}"
      end
    end

    def try_compute comp
      info 1,"processing #{comp.name}"
      if comp.inputs.all?{|input| @min_max[input]!=nil}
        min_max_ary=comp.inputs.collect{|input| @min_max[input]}
        min=min_max_ary.map{|ary| ary.min}.min
        max=min_max_ary.map{|ary| ary.max}.max
        delay=comp.infos[:delay]
        min_max=[min+delay,max+delay]
        comp.outputs.each do |output|
          @min_max[output]=min_max
          propagate(output)
        end
      else # need to retry later.
        @fifo << comp
      end
    end

    def propagate source
      source.sinks.each{|sink| @min_max[sink]=@min_max[source]}
    end

  end
end
