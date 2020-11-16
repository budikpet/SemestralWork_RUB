# frozen_string_literal: true

class SpecUtils
  include Enumerable

  # Changes standard output to StringIO to catch `puts` of the base_replace method
  # Changes standard output back after base_replace is done
  # @return [Array[String]] a $stdout in the form of array of strings which were split by newlines.
  def self.test_with_output
    return enum_for(:each) unless block_given?

    last_stdout = $stdout
    $stdout = StringIO.new
    yield
    output = $stdout.string.split("\n")
    $stdout = last_stdout

    output
  end
end
