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
        If folders are provided then the default behavior is to rename files they contain.
    LONGDESC
    method_option :find_str, type: :string, aliases: '-f', required: true, desc: 'The plain string to be found in filenames.'
    method_option :replace_str, type: :string, aliases: '-r', default: '', desc: 'The plain string that is to replace the found string.'
    method_option :dry_run, type: :boolean, aliases: '-d', default: false, desc: 'If this flag is set then the command runs without making changes to the given files.'
    method_option :replace_mode, type: :string, aliases: '-m', default: ReplaceModes::FILES_ONLY, enum: ReplaceModes.all_values, desc: 'If this flag is set then all given folders will be renamed instead of their content.'
    def base_replace(*files_folders)
      cli_logic = CLI_Logic.new
      cli_logic.base_replace(options[:find_str], options[:replace_str], options[:dry_run], options[:replace_mode], files_folders)

      # if find_str.nil?
      #   CLI.command_help(Thor::Base.shell.new, 'base_replace')
      #   nil
      # end
      # cli_logic = CLI_Logic.new
      # puts cli_logic.renamer_method_logic(arabic_cmd, renamer_cmd)
    end
  end
end
