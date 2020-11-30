# frozen_string_literal: true

require_relative 'renamer/cli_logic'
require_relative 'renamer/replace_modes'
require 'bundler/setup'
require 'thor'

module Renamer
  # A special string variable that is used to indicate where numbers of format command should be
  NUM_LOCATOR = '\i'

  # Thor CLI interface for Renamer CLI utility.
  class CLI < Thor
    desc 'base-replace [FILE_PATHS]', ''
    long_desc <<-LONGDESC
      Loads the given files and all files in the given folders.
      Renames them by finding given string and replacing it with another given string.

      FILE_PATHS:
        \x5
        Contains filepaths to files and/or folders that should be renamed.\x5
        If folders are provided and files are to be renamed then the default behavior is to rename files they contain.
    LONGDESC
    method_option :find_str, type: :string, aliases: '-f', required: true, desc: 'The plain string to be found in filenames.'
    method_option :replace_str, type: :string, aliases: '-r', default: '', desc: 'The plain string that is to replace the found string.'
    method_option :dry_run, type: :boolean, aliases: '-d', default: false, desc: 'If this flag is set then the command runs without making changes to the given files.'
    method_option :replace_mode, type: :string, aliases: '-m', default: ReplaceModes::ALL, enum: ReplaceModes.all_values, desc: 'Sets the mode to replace names of only files, only folders or all'
    def base_replace(*files_folders)
      cli_logic = CLI_Logic.new

      begin
        cli_logic.base_replace(options[:find_str], options[:replace_str], options[:dry_run], options[:replace_mode], files_folders)
      rescue ArgumentError => e
        puts "ERROR OCCURED: #{e.message}"
        puts ''
        CLI.command_help(Thor::Base.shell.new, 'add-text')
      end
    end

    desc 'regex-replace [FILE_PATHS]', ''
    long_desc <<-LONGDESC
      Loads the given files and all files in the given folders.
      Renames them by finding given regex string and replacing it with another given regex.

      FILE_PATHS:
        \x5
        Contains filepaths to files and/or folders that should be renamed.\x5
        If folders are provided and files are to be renamed then the default behavior is to rename files they contain.
    LONGDESC
    method_option :find_str, type: :string, aliases: '-f', required: true, desc: 'The regex string to be found in filenames.'
    method_option :replace_str, type: :string, aliases: '-r', default: '', desc: 'The base string that is to replace the found string.'
    method_option :dry_run, type: :boolean, aliases: '-d', default: false, desc: 'If this flag is set then the command runs without making changes to the given files.'
    method_option :replace_mode, type: :string, aliases: '-m', default: ReplaceModes::ALL, enum: ReplaceModes.all_values, desc: 'Sets the mode to replace names of only files, only folders or all'
    def regex_replace(*files_folders)
      cli_logic = CLI_Logic.new

      begin
        cli_logic.regex_replace(options[:find_str], options[:replace_str], options[:dry_run], options[:replace_mode], files_folders)
      rescue ArgumentError => e
        puts "ERROR OCCURED: #{e.message}"
        puts ''
        CLI.command_help(Thor::Base.shell.new, 'add-text')
      end
    end

    desc 'add-text [FILE_PATHS]', ''
    long_desc <<-LONGDESC
      Loads the given files and all files in the given folders.
      Renames them by appending and/or prepending provided text.

      FILE_PATHS:
        \x5
        Contains filepaths to files and/or folders that should be renamed.\x5
        If folders are provided and files are to be renamed then the default behavior is to rename files they contain.
    LONGDESC
    method_option :prepend, type: :string, aliases: '-p', desc: 'The text to prepend to filenames.'
    method_option :append, type: :string, aliases: '-a', desc: 'The text to append to filenames.'
    method_option :dry_run, type: :boolean, aliases: '-d', default: false, desc: 'If this flag is set then the command runs without making changes to the given files.'
    method_option :replace_mode, type: :string, aliases: '-m', default: ReplaceModes::ALL, enum: ReplaceModes.all_values, desc: 'Sets the mode to replace names of only files, only folders or all'
    def add_text(*files_folders)
      cli_logic = CLI_Logic.new

      begin
        cli_logic.add_text(options[:prepend], options[:append], options[:dry_run], options[:replace_mode], files_folders)
      rescue ArgumentError => e
        puts "ERROR OCCURED: #{e.message}"
        puts ''
        CLI.command_help(Thor::Base.shell.new, 'add-text')
      end
    end

    desc 'format [FILE_PATHS]', ''
    long_desc <<-LONGDESC
      Loads the given files and all files in the given folders.
      Renames them using a specified format regardless of their current name.

      FILE_PATHS:
        \x5
        Contains filepaths to files and/or folders that should be renamed.\x5
        If folders are provided and files are to be renamed then the default behavior is to rename files they contain.
    LONGDESC
    method_option :file_format, type: :string, aliases: '-f', default: "File#{NUM_LOCATOR}", desc: "A format (text) of renamed files. A string `#{NUM_LOCATOR}` tells where the files number is going to be. If `#{NUM_LOCATOR}` is missing then it is appended at the end by default."
    method_option :dir_format, type: :string, aliases: '-dir', default: "Folder#{NUM_LOCATOR}", desc: "A format (text) of renamed folders. A string `#{NUM_LOCATOR}` tells where the files number is going to be. If `#{NUM_LOCATOR}` is missing then it is appended at the end by default."
    method_option :file_initial_num, type: :numeric, aliases: '-fn', default: 0, desc: 'Initial number for renamed files.'
    method_option :dir_initial_num, type: :numeric, aliases: '-dn', default: 0, desc: 'Initial number for renamed folders.'
    method_option :dry_run, type: :boolean, aliases: '-d', default: false, desc: 'If this flag is set then the command runs without making changes to the given files.'
    def format(*files_folders)
      cli_logic = CLI_Logic.new

      begin
        cli_logic.format(options[:file_format], options[:dir_format],
                         options[:file_initial_num], options[:dir_initial_num],
                         options[:dry_run], files_folders)
      rescue ArgumentError => e
        puts "ERROR OCCURED: #{e.message}"
        puts ''
        CLI.command_help(Thor::Base.shell.new, 'add-text')
      end
    end
  end
end
