# frozen_string_literal: true

require_relative 'renamer/cli_logic'
require_relative 'renamer/replace_modes'
require 'bundler/setup'
Bundler.require(:default, :development)

module Renamer
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
      cli_logic.base_replace(options[:find_str], options[:replace_str], options[:dry_run], options[:replace_mode], files_folders)
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
      cli_logic.regex_replace(options[:find_str], options[:replace_str], options[:dry_run], options[:replace_mode], files_folders)
    end
  end
end
