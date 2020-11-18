# frozen_string_literal: true

require 'rspec'
require 'renamer'
require 'fileutils'
require 'tmpdir'
require 'pathname'
require 'stringio'
require_relative '../spec_helper'
require_relative '../spec_utils'

describe 'Renamer::CLI_Logic, add_text command: ' do
  before(:all) do
    @used_tmp_dirs = []
  end

  before(:each) do
    # Prepare file structure
    @tmp_dir = Dir.mktmpdir('rspec-')
    @used_tmp_dirs.push @tmp_dir
    FileUtils.mkdir_p "#{@tmp_dir}/temp"

    FileUtils.touch("#{@tmp_dir}/temp/temp.txt")
    FileUtils.touch("#{@tmp_dir}/temp/temp2.txt")
  end

  subject(:cli_logic) { Renamer::CLI_Logic.new }

  it '@tmp_dir should exist' do
    expect(Dir.exist?(@tmp_dir)).to be true
  end

  it 'checks append and prepend text adding' do
    prepend = 't_'
    append = '_d'

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.add_text(prepend, append, false, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Prepend text `#{prepend}` and append text `#{append}`."
    expect(output.count { |str| str.include? 'Renamed `temp2.txt` -> `t_temp2_d.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp.txt` -> `t_temp_d.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp` -> `t_temp_d`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['t_temp2_d.txt', 't_temp_d.txt'].sort
    expect(curr_dirs).to eq ['t_temp_d'].sort
  end

  it 'checks prepend only text adding' do
    prepend = 't_'
    append = nil

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.add_text(prepend, append, false, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Prepend text `#{prepend}`."
    expect(output.count { |str| str.include? 'Renamed `temp2.txt` -> `t_temp2.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp.txt` -> `t_temp.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp` -> `t_temp`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['t_temp2.txt', 't_temp.txt'].sort
    expect(curr_dirs).to eq ['t_temp'].sort
  end

  it 'checks append only text adding' do
    prepend = nil
    append = '_d'

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.add_text(prepend, append, false, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Append text `#{append}`."
    expect(output.count { |str| str.include? 'Renamed `temp2.txt` -> `temp2_d.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp.txt` -> `temp_d.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp` -> `temp_d`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['temp2_d.txt', 'temp_d.txt'].sort
    expect(curr_dirs).to eq ['temp_d'].sort
  end

  after(:all) do
    @used_tmp_dirs.each do |path|
      FileUtils.remove_dir(path)
    end
  end
end
