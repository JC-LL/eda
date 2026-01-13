module EDA

  class Port
    include InfoDisplay
    attr_accessor :name
    attr_accessor :component
    attr_accessor :source,:sinks
    attr_accessor :value
    def initialize name
      @name=Var.new(name.to_s)
      @sinks=[]
      @source=nil
    end

    def connect target
      info 2,"connecting #{self} => #{target}"  if $verbose
      @sinks << target
      @sinks.uniq!
      target.source=self
    end

    def to_s
      "#{component.name}.#{name}"
    end
  end

  class Input < Port
  end

  class Output < Port
  end

  class Circuit
    @@id=-1
    attr_accessor :name
    attr_accessor :inputs,:outputs,:components
    attr_accessor :delay
    attr_accessor :component

    def initialize name=nil
      @name=name || "#{self.class}_#{@@id+=1}"
      @inputs,@outputs=[],[]
      @components=[]
    end

    def <<(e)
      e.component=self
      case e
      when Input
        @inputs << e
        @inputs.uniq!
      when Output
        @outputs << e
        @outputs.uniq!
      when Circuit
        @components << e
        @components.uniq!
      end
    end

    def create i_or_o, name
      case i_or_o
      when :input
        self << port=Input.new(name)
      when :output
        self << port=Output.new(name)
      end
      port
    end

    def get_port_named name
      ports=[@inputs,@outputs].flatten
      ports.find{|port| port.name.to_s==name.to_s}
    end

    def get_average_fanout
      port_fanout_h={}
      @inputs.each do |input|
        port_fanout_h[input]=input.sinks.size
      end
      @components.each do |comp|
        comp.outputs.each do |output|
          port_fanout_h[output]=output.sinks.size
        end
      end
      port_fanout_h.values.sum.to_f / port_fanout_h.size
    end

    def get_regs
      @components.select{|comp| comp.is_a?(EDA::Dff)}
    end

    def get_comb_seq
      @components.partition{|comp| comp.is_a?(EDA::Dff)}
    end

    def ports
      [inputs,outputs].flatten
    end
  end

  class Gate1 < Circuit
    def initialize
      super
      self << Input.new(:i)
      self << Output.new(:f)
    end
  end

  class Gate2 < Circuit
    def initialize
      super
      self << Input.new(:i0)
      self << Input.new(:i1)
      self << Output.new(:f)
    end
  end

  class Dff < Circuit
    def initialize
      super
      self << Input.new(:d)
      self << Output.new(:q)
    end
  end
end
