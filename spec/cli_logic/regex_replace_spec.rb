# frozen_string_literal: true

require 'rspec'
require 'renamer'
require 'fileutils'
require 'tmpdir'
require 'pathname'
require 'stringio'
require_relative '../spec_helper'
require_relative '../spec_utils'

describe 'Renamer::CLI_Logic, regex_replace command: ' do
  before(:all) do
    @used_tmp_dirs = []
  end

  before(:each) do
    # Prepare file structure
    @tmp_dir = Dir.mktmpdir('rspec-')
    @used_tmp_dirs.push @tmp_dir
    FileUtils.mkdir_p "#{@tmp_dir}/temp"

    FileUtils.touch("#{@tmp_dir}/temp/12ah34oj56789.txt")
  end

  subject(:cli_logic) { Renamer::CLI_Logic.new }

  it '@tmp_dir should exist' do
    expect(Dir.exist?(@tmp_dir)).to be true
  end

  it 'checks if basic regex works' do
    find_str = '\d'
    replace_str = ''

    # Changes standard output to StringIO to catch `puts` of the regex_replace method
    # Changes standard output back after regex_replace is done
    output = SpecUtils.test_with_output do
      subject.regex_replace(find_str, replace_str, false, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? 'Renamed `12ah34oj56789.txt` -> `ahoj.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `temp`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['ahoj.txt'].sort
    expect(curr_dirs).to eq ['temp'].sort
  end

  it 'checks dry run' do
    find_str = '\d'
    replace_str = ''

    # Changes standard output to StringIO to catch `puts` of the regex_replace method
    # Changes standard output back after regex_replace is done
    output = SpecUtils.test_with_output do
      subject.regex_replace(find_str, replace_str, true, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? 'Would rename `12ah34oj56789.txt` -> `ahoj.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern would have no effect on `temp`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['12ah34oj56789.txt'].sort
    expect(curr_dirs).to eq ['temp'].sort
  end

  it 'checks behaviour when file with a new name already exists' do
    find_str = '\d'
    replace_str = ''

    FileUtils.touch("#{@tmp_dir}/temp/ahoj.txt")

    # Changes standard output to StringIO to catch `puts` of the regex_replace method
    # Changes standard output back after regex_replace is done
    output = SpecUtils.test_with_output do
      subject.regex_replace(find_str, replace_str, false, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? 'Won`t rename `12ah34oj56789.txt` -> `ahoj.txt` since it already exists.' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `temp`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['12ah34oj56789.txt', 'ahoj.txt'].sort
    expect(curr_dirs).to eq ['temp'].sort
  end

  it 'checks dry_run behaviour when multiple files are renamed to the same name' do
    find_str = '\d'
    replace_str = ''

    FileUtils.touch("#{@tmp_dir}/temp/0ahoj74.txt")

    # Changes standard output to StringIO to catch `puts` of the regex_replace method
    # Changes standard output back after regex_replace is done
    output = SpecUtils.test_with_output do
      subject.regex_replace(find_str, replace_str, true, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? 'Would rename `0ahoj74.txt` -> `ahoj.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Wouldn`t rename `12ah34oj56789.txt` -> `ahoj.txt` since it already exists.' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern would have no effect on `temp`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['12ah34oj56789.txt', '0ahoj74.txt'].sort
    expect(curr_dirs).to eq ['temp'].sort
  end

  after(:all) do
    @used_tmp_dirs.each do |path|
      FileUtils.remove_dir(path)
    end
  end
end
