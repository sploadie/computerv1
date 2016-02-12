class Options
  attr_reader :verbose

  @verbose = false

  def initialize(options_array)
    options_array.each do |option|
      case option.downcase
      when '-v' || '-verbose'
        @verbose = true
      else
        raise ArgumentError, "#{option} is not a valid option", caller
      end
    end
  end

end