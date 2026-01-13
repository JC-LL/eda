module EDA
  class Var
    @@id=-1
    attr_accessor :name
    def initialize name=nil
      @name=name || "i#{@@id+=1}"
    end

    def to_s
      @name
    end
  end

  BINARY_OPS=[:and,:or,:xor,:nor,:nand]
  class Binary
    attr_accessor :op,:lhs,:rhs
    def initialize op,lhs,rhs
      @op,@lhs,@rhs=op,lhs,rhs
    end

    def to_s
      return @str if @str
      @str="(#{op} #{lhs.to_s} #{rhs.to_s})"
    end
  end

  UNARY_OPS=[:not,:yes]
  class Unary
    attr_accessor :op,:expr
    def initialize op,expr
      @op,@expr=op,expr
    end

    def to_s
      return @str if @str
      @str="(#{op} #{expr.to_s})"
    end
  end

  OPS=[BINARY_OPS,UNARY_OPS].flatten

  class Equation < Binary
    def initialize lhs,rhs
      super(:eq,lhs,rhs)
    end

    def to_s
      "#{lhs.to_s} = #{rhs.to_s}"
    end
  end
end
