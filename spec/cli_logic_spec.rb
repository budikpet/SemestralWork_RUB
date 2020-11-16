# frozen_string_literal: true

require 'rspec'
require 'renamer'
require 'fileutils'
require 'tmpdir'
require 'pathname'
require 'stringio'
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
  before(:all) do
    @used_tmp_dirs = []
  end

  before(:each) do
    # Prepare file structure
    @tmp_dir = Dir.mktmpdir('rspec-')
    @used_tmp_dirs.push @tmp_dir
    FileUtils.mkdir_p "#{@tmp_dir}/in_temp/in_in_temp"
    FileUtils.mkdir_p "#{@tmp_dir}/in_temp2"

    FileUtils.touch("#{@tmp_dir}/temp.txt")
    FileUtils.touch("#{@tmp_dir}/temp2.txt")
    FileUtils.touch("#{@tmp_dir}/in_temp/temp3temp.txt")
    FileUtils.touch("#{@tmp_dir}/in_temp/in_in_temp/4temp.txt")
    FileUtils.touch("#{@tmp_dir}/in_temp2/other.txt")
  end

  subject(:cli_logic) { Renamer::CLI_Logic.new }

  it '@tmp_dir should exist' do
    expect(Dir.exist?(@tmp_dir)).to be true
  end

  describe 'base_replace command, ALL mode: ' do
    it 'only files' do
      find_str = 'temp'
      replace_str = 't'

      # Changes standard output to StringIO to catch `puts` of the base_replace method
      # Changes standard output back after base_replace is done
      last_stdout = $stdout
      $stdout = StringIO.new
      subject.base_replace(find_str, replace_str, false, ReplaceModes::ALL, [@tmp_dir])
      output = $stdout.string.split("\n")
      $stdout = last_stdout

      # Check output
      expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."

      current_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
      curr_dirs = current_files.select(&:directory?)
      current_files = current_files.select(&:file?).map { |path| File.basename(path) }.sort

      # Check file system

      expect(current_files.empty?).to eq false
      expect(current_files).to eq ['4t.txt', 't.txt', 't2.txt', 't3t.txt', 'other.txt'].sort
    end

    after(:all) do
      @used_tmp_dirs.each do |path|
        FileUtils.remove_dir(path)
      end
    end
  end
end
