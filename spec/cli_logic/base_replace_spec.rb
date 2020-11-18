# frozen_string_literal: true

require 'rspec'
require 'renamer'
require 'fileutils'
require 'tmpdir'
require 'pathname'
require 'stringio'
require_relative '../spec_helper'
require_relative '../spec_utils'

describe 'Renamer::CLI_Logic, base_replace command: ' do
  before(:all) do
    @used_tmp_dirs = []
  end

  before(:each) do
    # Prepare file structure
    @tmp_dir = Dir.mktmpdir('rspec-')
    @used_tmp_dirs.push @tmp_dir
    FileUtils.mkdir_p "#{@tmp_dir}/temp/in_temp/in_in_temp"
    FileUtils.mkdir_p "#{@tmp_dir}/temp/in_temp2"

    FileUtils.touch("#{@tmp_dir}/temp/temp.txt")
    FileUtils.touch("#{@tmp_dir}/temp/temp2.txt")
    FileUtils.touch("#{@tmp_dir}/temp/in_temp/temp3temp.txt")
    FileUtils.touch("#{@tmp_dir}/temp/in_temp2/other.txt")
    FileUtils.touch("#{@tmp_dir}/temp/in_temp/in_in_temp/4temp.txt")
  end

  subject(:cli_logic) { Renamer::CLI_Logic.new }

  it '@tmp_dir should exist' do
    expect(Dir.exist?(@tmp_dir)).to be true
  end

  it 'checks ALL mode' do
    find_str = 'temp'
    replace_str = 't'

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.base_replace(find_str, replace_str, false, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `other.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `4temp.txt` -> `4t.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp3temp.txt` -> `t3t.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp2.txt` -> `t2.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp.txt` -> `t.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_in_temp` -> `in_in_t`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_temp` -> `in_t' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp` -> `t`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['4t.txt', 't.txt', 't2.txt', 't3t.txt', 'other.txt'].sort
    expect(curr_dirs).to eq ['t', 'in_t', 'in_t2', 'in_in_t'].sort
  end

  it 'checks FILES_ONLY mode' do
    find_str = 'temp'
    replace_str = 't'

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.base_replace(find_str, replace_str, false, ReplaceModes::FILES_ONLY, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `other.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `4temp.txt` -> `4t.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp3temp.txt` -> `t3t.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp2.txt` -> `t2.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp.txt` -> `t.txt`' }).to eq 1
    expect(output.count { |str| str.include? '`in_in_temp`' }).to eq 0
    expect(output.count { |str| str.include? '`in_temp`' }).to eq 0

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['4t.txt', 't.txt', 't2.txt', 't3t.txt', 'other.txt'].sort
    expect(curr_dirs).to eq ['temp', 'in_temp', 'in_temp2', 'in_in_temp'].sort
  end

  it 'checks FOLDERS_ONLY mode' do
    find_str = 'temp'
    replace_str = 't'

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.base_replace(find_str, replace_str, false, ReplaceModes::FOLDERS_ONLY, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? '`other.txt`' }).to eq 0
    expect(output.count { |str| str.include? '`4temp.txt`' }).to eq 0
    expect(output.count { |str| str.include? '`temp3temp.txt``' }).to eq 0
    expect(output.count { |str| str.include? '`temp2.txt`' }).to eq 0
    expect(output.count { |str| str.include? '`temp.txt`' }).to eq 0
    expect(output.count { |str| str.include? 'Renamed `in_in_temp` -> `in_in_t`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_temp` -> `in_t' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp` -> `t`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['4temp.txt', 'temp.txt', 'temp2.txt', 'temp3temp.txt', 'other.txt'].sort
    expect(curr_dirs).to eq ['t', 'in_t', 'in_t2', 'in_in_t'].sort
  end

  it 'checks dry run' do
    find_str = 'temp'
    replace_str = 't'

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.base_replace(find_str, replace_str, true, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? 'Provided pattern would have no effect on `other.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Would rename `4temp.txt` -> `4t.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Would rename `temp3temp.txt` -> `t3t.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Would rename `temp2.txt` -> `t2.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Would rename `temp.txt` -> `t.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Would rename `in_in_temp` -> `in_in_t`' }).to eq 1
    expect(output.count { |str| str.include? 'Would rename `in_temp` -> `in_t' }).to eq 1
    expect(output.count { |str| str.include? 'Would rename `temp` -> `t`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['4temp.txt', 'temp.txt', 'temp2.txt', 'temp3temp.txt', 'other.txt'].sort
    expect(curr_dirs).to eq ['temp', 'in_temp', 'in_temp2', 'in_in_temp'].sort
  end

  it 'checks if it does not rename files which would have empty name' do
    find_str = 'temp'
    replace_str = ''

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.base_replace(find_str, replace_str, false, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `other.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `4temp.txt` -> `4.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp3temp.txt` -> `3.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp2.txt` -> `2.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `temp.txt` -> `.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_in_temp` -> `in_in_`' }).to eq 1
    expect(output.count { |str| str.include? 'Renamed `in_temp` -> `in_' }).to eq 1
    expect(output.count { |str| str.include? 'Won`t rename `temp` -> ``' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*", File::FNM_DOTMATCH)
                    .reject { |a| ['..', '.'].include? File.basename a }
                    .map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['4.txt', '.txt', '2.txt', '3.txt', 'other.txt'].sort
    expect(curr_dirs).to eq ['temp', 'in_', 'in_2', 'in_in_'].sort
  end

  it 'checks behaviour when file with a new name already exists' do
    find_str = '2'
    replace_str = ''

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.base_replace(find_str, replace_str, false, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `other.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `4temp.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `temp3temp.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Won`t rename `temp2.txt` -> `temp.txt` since it already exists' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `temp.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `in_in_temp`' }).to eq 1
    expect(output.count { |str| str.include? 'Won`t rename `in_temp2` -> `in_temp` since it already exists' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `in_temp`' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern has no effect on `temp`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['4temp.txt', 'temp.txt', 'temp2.txt', 'temp3temp.txt', 'other.txt'].sort
    expect(curr_dirs).to eq ['temp', 'in_temp', 'in_temp2', 'in_in_temp'].sort
  end

  it 'checks dry_run behaviour when file with a new name already exists' do
    find_str = '2'
    replace_str = ''

    # Changes standard output to StringIO to catch `puts` of the base_replace method
    # Changes standard output back after base_replace is done
    output = SpecUtils.test_with_output do
      subject.base_replace(find_str, replace_str, true, ReplaceModes::ALL, [@tmp_dir + '/temp'])
    end

    # puts output.join("\n")

    # Check output
    expect(output[0]).to eq "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
    expect(output.count { |str| str.include? 'Provided pattern would have no effect on `other.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern would have no effect on `4temp.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern would have no effect on `temp3temp.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Wouldn`t rename `temp2.txt` -> `temp.txt` since it already exists' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern would have no effect on `temp.txt`' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern would have no effect on `in_in_temp`' }).to eq 1
    expect(output.count { |str| str.include? 'Wouldn`t rename `in_temp2` -> `in_temp` since it already exists' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern would have no effect on `in_temp`' }).to eq 1
    expect(output.count { |str| str.include? 'Provided pattern would have no effect on `temp`' }).to eq 1

    curr_files = Dir.glob("#{@tmp_dir}/**/*").map { |path| Pathname.new(path) }
    curr_dirs = curr_files.select(&:directory?).map { |path| path.basename.to_s }.sort
    curr_files = curr_files.select(&:file?).map { |path| path.basename.to_s }.sort

    # Check file system

    expect(curr_files.empty?).to eq false
    expect(curr_dirs.empty?).to eq false
    expect(curr_files).to eq ['4temp.txt', 'temp.txt', 'temp2.txt', 'temp3temp.txt', 'other.txt'].sort
    expect(curr_dirs).to eq ['temp', 'in_temp', 'in_temp2', 'in_in_temp'].sort
  end

  it 'checks errors' do
    f = 'temp'
    r = 't'
    m = ReplaceModes::ALL

    expect { subject.base_replace(f, r, false, m, []) }.to raise_error(ArgumentError)
    expect { subject.base_replace(f, r, false, m, nil) }.to raise_error(ArgumentError)
    expect { subject.base_replace(f, r, false, m, [@tmp_dir + 'someDir']) }.to raise_error(ArgumentError)
    expect { subject.base_replace(nil, r, false, m, [@tmp_dir]) }.to raise_error(ArgumentError)
  end

  after(:all) do
    @used_tmp_dirs.each do |path|
      FileUtils.remove_dir(path)
    end
  end
end
