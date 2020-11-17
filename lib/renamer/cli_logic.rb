# frozen_string_literal: true

require_relative 'replace_modes'

module Renamer
  # Implements logic of the created CLI command.
  class CLI_Logic
    # Contains logic of base_replace CLI command.
    # Finds a basic string in names of given files and/or folders and replaces it with another string.
    # @param find_str [String] - a string to find & to be replaced in names of the given files and/or folders
    # @param replace_str [String] - a string to be used as a replacement in names of files and/or folders
    # @param dry_run [boolean] - true <=> we want to print out what would happen without making changes in the file_system
    # @param replace_mode [ReplaceMode] - tells the system whether file names, directory names or all given names should be changed
    # @param files_folders [Array<String>] - an array of all files and/or folders to be renamed
    def base_replace(find_str, replace_str, dry_run, replace_mode, files_folders)
      paths = get_paths(replace_mode, files_folders)

      # Do replacement

      puts "Find pattern `#{find_str}` in names and replace it with `#{replace_str}`."
      rename_files(paths, dry_run) do |curr_path, _|
        curr_name = curr_path.basename.to_s
        curr_name.gsub(find_str, replace_str)
      end
    end

    # Contains logic of regex_replace CLI command.
    # Matches a given regex in names of given files and/or folders and replaces it using another regex.
    # @param find_str [String] - a regex string to find & to be replaced in names of the given files and/or folders
    # @param replace_str [String] - a base string to be used as a replacement in names of files and/or folders
    # @param dry_run [boolean] - true <=> we want to print out what would happen without making changes in the file_system
    # @param replace_mode [ReplaceMode] - tells the system whether file names, directory names or all given names should be changed
    # @param files_folders [Array<String>] - an array of all files and/or folders to be renamed
    def regex_replace(find_str, replace_str, dry_run, replace_mode, files_folders)
      find_str = Regexp.new(find_str.sub(%r{^/}, '').sub(%r{/$}, ''))
      paths = get_paths(replace_mode, files_folders)

      puts "Find pattern `#{find_str.source}` in names and replace it with `#{replace_str}`."
      rename_files(paths, dry_run) do |curr_path, _|
        curr_name = curr_path.basename.to_s
        curr_name.gsub(find_str, replace_str)
      end
    end

    private

    # Runs the logic of renaming files.
    # @raise [ArgumentError] if block is not given.
    #
    # for block {|curr_path, curr_index| ... }
    # @yield [curr_path, curr_index] Description of block
    # @yieldparam curr_path [Pathname] is the absolute path of the current file to be renamed
    # @yieldparam curr_index [Integer] is an index of the current file to be renamed in the input array
    # @yieldreturn [optional, types, ...] description
    def rename_files(paths, dry_run)
      raise ArgumentError, "Method `#{__method__}` needs to have a block for renaming files." unless block_given?

      if dry_run
        # Only print
        paths.each_with_index do |path, index|
          parent_folder = path.dirname
          curr_name = path.basename.to_s
          new_name = yield(path, index)
          if curr_name == new_name
            # Pattern not found in the current name. Do not rename
            puts "Provided pattern would have no effect on `#{curr_name}` [#{path}]"
          elsif new_name.empty?
            puts "Wouldn`t rename `#{curr_name}` -> `#{new_name}` [#{path}]"
          elsif (parent_folder + new_name).exist?
            puts "Wouldn`t rename `#{curr_name}` -> `#{new_name}` since it already exists. [#{path}]"
          else
            # Would rename file
            puts "Would rename `#{curr_name}` -> `#{new_name}` [#{path}]"
          end
        end
        return
      end

      paths.each_with_index do |path, index|
        parent_folder = path.dirname
        curr_name = path.basename.to_s
        new_name = yield(path, index)
        if curr_name == new_name
          # Pattern not found in the current name. Do not rename
          puts "Provided pattern has no effect on `#{curr_name}` [#{path}]"
        elsif new_name.empty?
          puts "Won`t rename `#{curr_name}` -> `#{new_name}` [#{path}]"
        elsif (parent_folder + new_name).exist?
          puts "Won`t rename `#{curr_name}` -> `#{new_name}` since it already exists. [#{path}]"
        else
          # Renamed file
          File.rename(path, parent_folder + new_name)
          puts "Renamed `#{curr_name}` -> `#{new_name}` [#{path}]"
        end
      end
    end

    # @param replace_mode [ReplaceMode] - tells the system whether file names, directory names or all given names should be changed
    # @param files_folders [Array<String>] - an array of all files and/or folders to be renamed
    # @return [Array<Pathname>] is a list of filesystem paths of files and/or folders that were picked from the input
    #   according to the given replace_mode
    def get_paths(replace_mode, files_folders)
      files, folders = separate_input_files(files_folders, replace_mode)

      if replace_mode == ReplaceModes::ALL
        # Change names in both folders and files
        paths = (files + folders)
      elsif replace_mode == ReplaceModes::FILES_ONLY
        paths = files
      elsif replace_mode == ReplaceModes::FOLDERS_ONLY
        paths = folders
      end

      paths
    end

    # Separates files and folders into their own lists. Looks recursively.
    #
    # @param files_folders [Array<String>] - a list of filesystem paths to files and/or folders
    # @param replace_mode [REPLACE_MODE] - currently used replace mode
    # @return [Array<Pathname>, Array<Pathname>] Two lists which contain only files and only folders in this order.
    #   If replace_mode is ALL or FILES_ONLY then list of files contains all subfiles of given folders.
    #   Files are sorted alphabetically, Folders are sorted by a length of their filesystem path descending.
    def separate_input_files(files_folders, replace_mode)
      files = []
      folders = []

      # Split input into files and folders
      files_folders
        .select { |path| File.exist? path }
        .each do |path|
          if File.directory? path
            folders.push Pathname.new(path)
            subfiles = Dir.glob("#{path}/**/*").map { |subpath| Pathname.new(subpath) }
            folders.push(subfiles.select(&:directory?))
            files.push(subfiles.select(&:file?)) if [ReplaceModes::ALL, ReplaceModes::FILES_ONLY].include? replace_mode
          else
            files.push Pathname.new(path)
          end
        end

      [files.flatten(1).sort.uniq, folders.flatten(1).sort_by { |x| x.to_s.length }.reverse.uniq]
    end
  end
end
