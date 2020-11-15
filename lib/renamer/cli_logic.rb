# frozen_string_literal: true

require_relative 'replace_modes'

module Renamer
  # Implements logic of the created CLI command.
  class CLI_Logic
    # Contains logic of base_replace CLI command
    def base_replace(find_str, replace_str, dry_run, replace_mode, files_folders)
      puts find_str
      puts replace_str
      puts dry_run
      puts replace_mode
      puts files_folders

      files, folders = separate_input_files(files_folders, replace_mode)

      puts "#{files}"
      puts "#{folders}"
    end

    private

    # Separates files and folders into their own lists. Looks recursively.
    #
    # @param files_folders [Array[String]] - a list of filesystem paths to files and/or folders
    # @param replace_mode [REPLACE_MODE] - currently used replace mode
    # @return [Array[String], Array[String]] Two lists which contain only files and only folders in this order.
    #   If replace_mode is ALL or FILES_ONLY then list of files contains all subfiles of given folders.
    def separate_input_files(files_folders, replace_mode)
      files = []
      folders = []

      # Split input into files and folders
      files_folders
        .filter { |path| File.exist? path }
        .each do |path|
          if File.directory? path
            folders.push path
            subfiles = Dir.glob("#{path}/**/*")
            folders.push(subfiles.select { |subpath| File.directory?(subpath) })
            if [ReplaceModes::ALL, ReplaceModes::FILES_ONLY].include? replace_mode
              files.push(subfiles.select { |subpath| File.file?(subpath) })
            end
          else
            files.push path
          end
        end

      [files.flatten(1).sort.uniq, folders.flatten(1).sort.uniq]
    end
  end
end
