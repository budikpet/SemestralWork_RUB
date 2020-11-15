# frozen_string_literal: true

require 'rspec'
require 'renamer'
require 'fileutils'
require 'tmpdir'
require_relative 'spec_helper'

def create_file(path)
  File.open(path, 'w') do |f|
    f.write('foo')
  end

  path
end

def create_folder(path)
  FileUtils.mkdir_p path
  path
end

describe 'Renamer::CLI_Logic' do
  # include_context :uses_temp_dir

  before(:all) do
    @tmp_dir = Dir.mktmpdir('rspec-')
    puts "BEFORE_ALL: `#{@tmp_dir}`"
  end

  subject(:cli_logic) { Renamer::CLI_Logic.new }

  it '@tmp_dir should exist' do
    expect(Dir.exist?(@tmp_dir)).to be true
  end

  describe 'check base_replace command: ' do
    it 'only files' do
      dir_path = "#{@tmp_dir}/"
      find_str = 'temp'
      replace_str = 'temporary'
      files = [
        create_file("#{@tmp_dir}/temp.txt"),
        create_file("#{@tmp_dir}/temp2.txt"),
        create_file("#{@tmp_dir}/temp3temp.txt"),
        create_file("#{@tmp_dir}/4temp.txt")
      ]
      # expect(File.read(temp_file)).to eq 'foo'
      current_files = Dir["#{@tmp_dir}/*"]
      dir_locations = current_files.collect { |path| File.dirname(path) }.uniq
      current_files = current_files.map { |path| File.basename(path) }.sort
      puts dir_locations

      expect(current_files.empty?).to eq false
      expect(dir_locations.size).to eq 1
      expect(current_files).to eq ['4temporary.txt', 'temporary.txt', 'temporary2.txt', 'temporary3temporary.txt'].sort
    end

    after(:all) do
      puts "AFTER_ALL: `#{@tmp_dir}`"
      FileUtils.remove_dir(@tmp_dir)
    end
  end

end
