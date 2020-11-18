# frozen_string_literal: true

require 'rspec'
require 'renamer'
require 'fileutils'
require 'tmpdir'
require 'pathname'
require 'stringio'
require_relative '../spec_helper'
require_relative '../spec_utils'

describe 'Renamer::CLI_Logic, format command: ' do
  before(:all) do
    @used_tmp_dirs = []
  end

  before(:each) do
    # Prepare file structure
    @tmp_dir = Dir.mktmpdir('rspec-')
    @used_tmp_dirs.push @tmp_dir
    FileUtils.mkdir_p "#{@tmp_dir}/temp/in_temp1"
    FileUtils.mkdir_p "#{@tmp_dir}/temp/in_temp2"

    FileUtils.touch("#{@tmp_dir}/temp/tempA.txt")
    FileUtils.touch("#{@tmp_dir}/temp/tempB.txt")
    FileUtils.touch("#{@tmp_dir}/temp/in_temp1/in_tempA.txt")
    FileUtils.touch("#{@tmp_dir}/temp/in_temp1/in_tempB.txt")
  end

  subject(:cli_logic) { Renamer::CLI_Logic.new }

  it '@tmp_dir should exist' do
    expect(Dir.exist?(@tmp_dir)).to be true
  end

  it 'checks basic format with all parameters' do
    file_format = 'File\i'
    dir_format = 'Folder\i'
    file_initial_num = 0
    dir_initial_num = 0

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.format(file_format, dir_format, file_initial_num, dir_initial_num, false, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Replacing names of files with format `#{file_format}`."
    expect(output[1]).to eq "Replacing names of folders with format `#{dir_format}`."
    expect(output.count { |str| str.include? 'Renamed `tempA.txt` -> `File0.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `tempB.txt` -> `File1.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_tempA.txt` -> `File0.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_tempB.txt` -> `File1.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_temp2` -> `Folder0`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_temp1` -> `Folder1`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp` -> `Folder0`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['File0.txt', 'File1.txt', 'File0.txt', 'File1.txt'].sort
    expect(curr_dirs).to eq ['Folder0', 'Folder1', 'Folder0'].sort
  end

  it 'checks all custom parameters' do
    file_format = '\iSomeFile\i'
    dir_format = '\iTheFolder\i'
    file_initial_num = 5
    dir_initial_num = 3

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.format(file_format, dir_format, file_initial_num, dir_initial_num, false, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Replacing names of files with format `#{file_format}`."
    expect(output[1]).to eq "Replacing names of folders with format `#{dir_format}`."
    expect(output.count { |str| str.include? 'Renamed `tempA.txt` -> `5SomeFile5.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `tempB.txt` -> `6SomeFile6.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_tempA.txt` -> `5SomeFile5.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_tempB.txt` -> `6SomeFile6.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_temp2` -> `3TheFolder3`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_temp1` -> `4TheFolder4`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp` -> `3TheFolder3`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['5SomeFile5.txt', '6SomeFile6.txt', '5SomeFile5.txt', '6SomeFile6.txt'].sort
    expect(curr_dirs).to eq ['3TheFolder3', '4TheFolder4', '3TheFolder3'].sort
  end

  it 'checks formats without special variable' do
    file_format = 'File'
    dir_format = 'Folder'
    file_initial_num = 0
    dir_initial_num = 0

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.format(file_format, dir_format, file_initial_num, dir_initial_num, false, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Replacing names of files with format `#{file_format}\\i`."
    expect(output[1]).to eq "Replacing names of folders with format `#{dir_format}\\i`."
    expect(output.count { |str| str.include? 'Renamed `tempA.txt` -> `File0.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `tempB.txt` -> `File1.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_tempA.txt` -> `File0.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_tempB.txt` -> `File1.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_temp2` -> `Folder0`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_temp1` -> `Folder1`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp` -> `Folder0`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['File0.txt', 'File1.txt', 'File0.txt', 'File1.txt'].sort
    expect(curr_dirs).to eq ['Folder0', 'Folder1', 'Folder0'].sort
  end

  it 'checks files-only command' do
    file_format = 'File\i'
    dir_format = nil
    file_initial_num = 0
    dir_initial_num = 0

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.format(file_format, dir_format, file_initial_num, dir_initial_num, false, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Replacing names of files with format `#{file_format}`."
    expect(output.count { |str| str.include? 'Replacing names of folders with format' }).to eq 0
    expect(output.count { |str| str.include? 'Renamed `tempA.txt` -> `File0.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `tempB.txt` -> `File1.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_tempA.txt` -> `File0.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_tempB.txt` -> `File1.txt`' }).to eq 1
    expect(output.count { |str| str.include? '`in_temp2`' }).to eq 0
    expect(output.count { |str| str.include? '`in_temp1`' }).to eq 0
    expect(output.count { |str| str.include? '`temp`' }).to eq 0

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['File0.txt', 'File1.txt', 'File0.txt', 'File1.txt'].sort
    expect(curr_dirs).to eq ['temp', 'in_temp1', 'in_temp2'].sort
  end

  it 'checks folders-only command' do
    file_format = nil
    dir_format = 'Folder\i'
    file_initial_num = 0
    dir_initial_num = 0

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.format(file_format, dir_format, file_initial_num, dir_initial_num, false, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Replacing names of folders with format `#{dir_format}`."
    expect(output.count { |str| str.include? 'Replacing names of files with format' }).to eq 0
    expect(output.count { |str| str.include? '`tempA.txt`' }).to eq 0
    expect(output.count { |str| str.include? '`tempB.txt`' }).to eq 0
    expect(output.count { |str| str.include? '`in_tempA.txt`' }).to eq 0
    expect(output.count { |str| str.include? '`in_tempB.txt`' }).to eq 0
    expect(output.count { |str| str.include? 'Renamed `in_temp2` -> `Folder0`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_temp1` -> `Folder1`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp` -> `Folder0`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['tempA.txt', 'tempB.txt', 'in_tempA.txt', 'in_tempB.txt'].sort
    expect(curr_dirs).to eq ['Folder0', 'Folder1', 'Folder0'].sort
  end

  it 'checks errors' do
    ff = 'File\i'
    df = 'Folder\i'
    fin = 0
    din = 0
    m = ReplaceModes::ALL

    # Test raises
    expect { subject.format(ff, df, fin, din, false, m, []) }.to raise_error(ArgumentError)
    expect { subject.format(ff, df, fin, din, false, m, nil) }.to raise_error(ArgumentError)
    expect { subject.format(ff, df, fin, din, false, m, [@tmp_dir + 'someDir']) }.to raise_error(ArgumentError)
    expect { subject.format(nil, nil, fin, din, false, m, [@tmp_dir]) }.to raise_error(ArgumentError)
    expect { subject.format('', '', fin, din, false, m, [@tmp_dir]) }.to raise_error(ArgumentError)
  end

  after(:all) do
    @used_tmp_dirs.each do |path|
      FileUtils.remove_dir(path)
    end
  end
end
