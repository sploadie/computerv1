def parse_part(part)
  # Split part into array
  part = part.gsub  /\s+/, ' '
  part = part.split /(\*|\+|\-)|\ /
  part.delete_if(&:empty?)

  raise 'a side of the equation is empty' if part.empty?

  # part last index
  last_i = part.count - 1

  # Change number-strings to floats
  part.map!.with_index do |val, i|
    # operator
    if ['*', '+', '-'].include? val
      #can't be at start or end or next to another operator
      raise 'unpaired operator' if i == 0 || i == last_i || ['*', '+', '-'].include?(part[i - 1]) || ['*', '+', '-'].include?(part[i + 1])
      # minus operand
      if val == '-'
        part[i + 1] = "-#{part[i + 1]}"
        val = '+'
      end
      next val.to_sym
    end
    # number
    val = Float(val) rescue val
    if val.is_a? Float
      next [val, 0]
    end
    # variable
    if val.include? 'X'
      x = val.split 'X'
      raise "invalid component in equation: #{val}" if x.count != 2
      # dealing with multiple
      x[0] += '1' if x[0].empty? || x[0] == '-'
      x[0] = Float(x[0]) rescue raise("invalid component in equation: #{val}")
      # dealing with factor
      if x[1].empty?
        x[1] = 1
        next x
      end
      raise "invalid component in equation: #{val}" if x[1][0] != '^'
      x[1][0] = ''
      x[1] = Float(x[1]) rescue raise("invalid component in equation: #{val}")
      raise "invalid component in equation: #{val}" if x[1] % 1 != 0
      x[1] = x[1].to_i
      next x
    end
    raise "invalid component in equation: #{val}"
  end
  return part
end

def solve_part(part)
  # solve multiplication
  while part.include? :* do
    part.each.with_index do |potential_operator, i|
      if potential_operator == :*
        # start at first value
        i = i - 1
        # collect operation parts
        val1     = part.delete_at i
        operator = part.delete_at i
        val2     = part.delete_at i
        puts "Operation: #{val1} #{operator} #{val2}"
        # check for valid components
        raise "invalid operation: #{val1} #{operator} #{val2}" unless val1.is_a?(Array) && val2.is_a?(Array)

        # multiply
        sum = [nil, nil]
        sum[0] = val1[0] * val2[0]
        sum[1] = val1[1] + val2[1]

        # insert back into equation
        part.insert i, sum
        break
      end
    end
  end
  x_array = [0.0, 0.0, 0.0]
  part.each do |val|
    next if val == :+
    raise "invalid equation half: #{val} is not a valid value" unless val.is_a? Array
    raise "invalid equation: X to the power of #{val[1]} is not permitted" unless [0,1,2].include? val[1]
    x_array[val[1]] += val[0]
  end
  return x_array
end

def parse(arguments)
  # DEBUG
  puts 'Arguments: ' + arguments.inspect
  # DEBUG

  raise 'needs an equation' if arguments.empty?

  equation = arguments.join(' ').upcase

  # DEBUG
  puts 'Equation: ' + equation
  # DEBUG

  halves = equation.split '='

  raise 'equation should have two sides' if halves.count != 2

  puts 'Halves: ' + halves.inspect

  halves.map! do |half|
    puts '=============='
    puts 'Half (initial): ' + half.inspect
    half = parse_part half
    puts 'Half (parsed): ' + half.inspect
    half = solve_part half
    puts 'Half (simplified): ' + half.inspect
    puts '=============='
    half
  end

  final_half = [0,1,2].map do |i|
    halves[0][i] - halves[1][i]
  end

  return final_half
end