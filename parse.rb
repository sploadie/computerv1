def verbose_puts(string)
  if $VERBOSE == true
    puts string
  end
end

def parse_part(part)
  # Split part into array
  part = part.gsub  /\s+/, ' '
  # part = part.split /(\*|\+|\-)|\ /
  part = part.split /(\*|\+)|\ /
  part.map! { |part_part| part_part.split /(?<!\^)(\-)/ }
  part.flatten!
  part.delete_if(&:empty?)

  raise ArgumentError, 'a side of the equation is empty' if part.empty?
  verbose_puts 'Half (split): ' + part.inspect

  # part last index
  last_i = part.count - 1

  # Change number-strings to floats
  part = part.map.with_index do |val, i|
    # operator
    if ['*', '+', '-'].include? val
      # handle stupid cases
      if ['+', '-'].include?(val) && ['+', '-'].include?(part[i + 1])
        if val == part[i + 1]
          part[i + 1] = '+'
        else
          part[i + 1] = '-'
        end
        next
      end
      # can't be at start or end or next to another operator
      raise ArgumentError, 'unpaired operator' if i == 0 || i == last_i || ['*', '+', '-'].include?(part[i + 1])
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
      if val == 'X'
        x = ['', '']
      elsif val[-1, 1] == 'X'
        x = [val.chop, '']
      else
        x = val.split 'X'
      end
      raise ArgumentError, "invalid component in equation: #{val}" if x.count != 2
      # dealing with multiple
      x[0] += '1' if x[0].empty? || x[0] == '-'
      x[0] = Float(x[0]) rescue raise(ArgumentError, "invalid component in equation: #{val}")
      # dealing with factor
      if x[1].empty?
        x[1] = 1
        next x
      end
      raise ArgumentError, "invalid component in equation: #{val}" if x[1][0] != '^'
      x[1][0] = ''
      x[1] = Float(x[1]) rescue raise(ArgumentError, "invalid component in equation: #{val}")
      raise ArgumentError, "not a polynomial: invalid component in equation: #{val}" if x[1] % 1 != 0
      x[1] = x[1].to_i
      next x
    end
    raise ArgumentError, "invalid component in equation: #{val}"
  end
  return part.compact
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
        verbose_puts "Operation: #{val1} #{operator} #{val2}"
        # check for valid components
        raise ArgumentError, "invalid operation: #{val1} #{operator} #{val2}" unless val1.is_a?(Array) && val2.is_a?(Array)

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
  x_array = []
  part.each do |val|
    next if val == :+
    raise ArgumentError, "invalid equation half: #{val} is not a valid value" unless val.is_a? Array
    raise ArgumentError, "invalid equation: not a polynomial" if val[1] < 0
    x_array[val[1]] = 0 if x_array[val[1]].nil?
    x_array[val[1]] += val[0]
  end
  return x_array
end

def parse(arguments)
  # DEBUG
  verbose_puts 'Arguments: ' + arguments.inspect
  # DEBUG

  raise ArgumentError, 'needs an equation' if arguments.empty?

  equation = arguments.join(' ').upcase

  # DEBUG
  verbose_puts 'Equation: ' + equation
  # DEBUG

  halves = equation.split '='

  raise ArgumentError, 'equation should have two sides' if halves.count != 2

  verbose_puts 'Halves: ' + halves.inspect

  halves.map! do |half|
    verbose_puts '=============='
    verbose_puts 'Half (initial): ' + half.inspect
    half = parse_part half
    verbose_puts 'Half (parsed): ' + half.inspect
    half = solve_part half
    verbose_puts 'Half (simplified): ' + half.inspect
    half
  end

  factors = halves[0].count > halves[1].count ? halves[0].count : halves[1].count

  final_half = []
  factors.times do |i|
    left  = halves[0][i].nil? ? 0.0 : halves[0][i]
    right = halves[1][i].nil? ? 0.0 : halves[1][i]
    final_half[i] = left - right
  end

  verbose_puts '=============='
  verbose_puts 'Final Half: ' + final_half.inspect
  verbose_puts '=============='
  return final_half
end