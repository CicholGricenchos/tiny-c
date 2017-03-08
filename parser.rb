require_relative './parser_util'

class Parser < ParserUtil

  rule :program do
    match :eof do
      []
    end

    match :function_definition, :program do
      @program.unshift @function_definition
    end
  end

  rule :function_definition do
    match :type, :iden, :formal_params, :block do
      [:define_func, @type[1], @iden[1], @formal_params, @block]
    end
  end

  rule :formal_params do
    match '(', ')' do
      []
    end

    match '(', :type, :iden, :formal_params_tail do
      @formal_params_tail.unshift [@type[1], @iden[1]]
    end
  end

  rule :formal_params_tail do
    match ')' do
      []
    end

    match ',', :type, :iden, :formal_params_tail do
      @formal_params_tail.unshift [@type[1], @iden[1]]
    end
  end

  rule :variable_definition do
    match :type, :iden, :assignment_operator, :expression do
      [:define_var, @type[1], @iden[1], @expression]
    end

    match :type, :iden do
      [:define_var, @type[1], @iden[1]]
    end
  end

  rule :type do
    match :iden do
      [:type, @iden[1]]
    end
  end

  rule :block do
    match '{', :statement, :block_tail do
      @block_tail.unshift @statement
    end
  end

  rule :block_tail do
    match '}' do
      []
    end

    match :statement, :block_tail do
      @block_tail.unshift @statement
    end
  end

  rule :statement do
    match :return, :expression, ';' do
      ['return', @expression]
    end

    match :if, '(', :expression, ')', :block, :else, :block do
      [:if, @expression, matched[4], matched[6]]
    end

    match :if, '(', :expression, ')', :block do
      [:if, @expression, @block]
    end

    match :variable_definition, ';' do
      @variable_definition
    end

    match :expression, ';' do
      @expression
    end
  end

  rule :expression do
    match :assignment_expression do
      @assignment_expression
    end

    match :assignment do
      @assignment
    end
  end

  rule :factor do
    match '(', :expression, ')' do
      @expression
    end

    match :number do
      @number[1]
    end

    match :int do
      [:int, @int[1].to_i]
    end

    match :function_call do
      @function_call
    end

    match :iden do
      [:get, @iden[1]]
    end

  end

  rule :function_call do
    match :iden, '(', ')' do
      [:call, @iden[1], []]
    end

    match :iden, '(', :actual_params, ')' do
      [:call, @iden[1], @actual_params]
    end
  end

  rule :actual_params do
    match :expression, :actual_params_tail do
      @actual_params_tail.unshift @expression
    end
  end

  rule :actual_params_tail do
    match ',', :expression, :actual_params_tail do
      @actual_params_tail.unshift @expression
    end

    match :empty do
      []
    end
  end

  binary_operation :assignment_expression, :assignment_operator, :relational_expression
  binary_operation :relational_expression, :relational_operator, :additive_expression
  binary_operation :additive_expression, :additive_operator, :multiplicative_expression
  binary_operation :multiplicative_expression, :multiplicative_operator, :factor

end