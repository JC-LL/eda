
module EDA

  TIMEOUT_POOL_GEN=0.1

  class EquationsGenerator

    include InfoDisplay

    def initialize vars,depth
      @vars=vars
      @depth=depth
      @pool={} #depth as key
      gen_pool()
    end

    def gen_equations nb_eqs
      info 1,"generating equations"
      eqns=nb_eqs.times.map{|i| gen_equation(i)}
      report_equations_sharing(eqns)
      return eqns
    end

    def report_equations_sharing equations
      info 1,"statistics about sub-expression sharing:"
      @refs={} # ref -> nb_subexpr
      old_ref_size=0
      total_expr=0
      equations.each_with_index do |eq,idx|
        nb_expr=count_expr(eq.rhs)
        total_expr+=nb_expr
        nb_refs=@refs.size-old_ref_size
        old_ref_size=@refs.size
        sharing=(1-nb_refs.to_f/nb_expr)*100
        info 2,"equation #{idx} : #{nb_expr.to_s.rjust(5)} expr / #{nb_refs.to_s.rjust(5)} refs : sharing = #{sharing.round(2)} %"
      end
      sharing=(1-@refs.size.to_f/total_expr)*100
      info 2,"total      : #{total_expr.to_s.rjust(5)} expr / #{@refs.size.to_s.rjust(5)} refs : sharing = #{sharing.round(2)} %"
    end

    private
    #===============================================================
    # theoretically : if d is the depth, n is the number of variables and p the number of binops.
    # the number L(0) of expressions for d=0 is L(0)= n
    # the number L(1) of expressions for d=1 is L(1)=p*C(2,n)^2
    # the number L(d) of expressions for d is   L(d)=L(d-1)*p*L(d-1)
    #===============================================================
    def gen_pool
      info 1,"building expressions pool"
      nvars=@vars.size
      nops=OPS.size
      begin
        Timeout.timeout(TIMEOUT_POOL_GEN) do
          gen_pool_rec(@depth)
        end
      rescue Timeout::Error
        info 2,"building interrupted by timeout"
        status="[interrompu]"
      end
      @pool.each do |depth,exprs|
        info 2,"depth = #{depth} -> #{exprs.size} expressions"
      end
    end

    def gen_pool_rec depth
      return @pool[depth] if @pool[depth]
      case depth
      when 0
        @pool[0]=@vars
      when 1
        @pool[1]=[]
        @vars.combination(2).each do |pair|
          BINARY_OPS.each do |op|
            @pool[1] << expr=Binary.new(op,*pair)
          end
        end
        @vars.each do |var|
          UNARY_OPS.each do |op|
            @pool[1] << expr=Unary.new(op,var)
          end
        end
      else
        gen_pool_rec(depth-1)
        @pool[depth]=[]
        subexprs=[@pool[depth-1],@pool[depth-1]].flatten
        subexprs.combination(2).each do |pair|
          BINARY_OPS.each do |op|
            @pool[depth] << expr=Binary.new(op,*pair)
          end
        end
        @pool[depth-1].each do |expr|
          UNARY_OPS.each do |op|
            @pool[depth] << expr=Unary.new(op,expr)
          end
        end
      end
    end

    def gen_expr depth
      if @pool[depth] && @pool[depth].any?
        return @pool[depth].sample
      else
        op=OPS.sample
        if is_unary?(op)
          return Unary.new(op,get_expr(depth))
        else
          lhs=get_expr(depth)
          rhs=get_expr(depth)
          return Binary.new(op,lhs,rhs)
        end
      end
    end

    def get_expr depth
      if @pool[depth] && @pool[depth].any?
        return @pool[depth].sample
      else
        return gen_expr(depth-1)
      end
    end

    def is_unary?(op)
      UNARY_OPS.include?(op)
    end

    def gen_equation i
      info 2,"generating equation #{i}"
      eqn=Equation.new(Var.new("y#{i}"),gen_expr(@depth))
      report_eqn(eqn)
      eqn
    end

    def count_expr expr
      if size=@refs[expr]
        return size
      end
      case unary=binary=expr
      when Var
        return 0
      when Unary
        val=1+count_expr(unary.expr)
      when Binary
        val=1+count_expr(binary.lhs)+count_expr(binary.rhs)
      end
      @refs[expr]=val
      return val
    end

    def report_eqn eqn,max_str_length=120
      str=eqn.to_s
      dots= (str.size > max_str_length) ? "...<skip>" : ""
      info 3,str.to_s[0..max_str_length-1]+dots
    end
  end

end
