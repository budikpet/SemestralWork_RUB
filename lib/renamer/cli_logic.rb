# frozen_string_literal: true

require 'set'
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
      raise ArgumentError, 'No files or folders provided for renaming.' if files_folders.empty?
      unless files_folders.any? { |path| File.exist?(path) }
        raise ArgumentError, 'Neither of provided files or folders exists.'
      end

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
      raise ArgumentError, 'No files or folders provided for renaming.' if files_folders.empty?
      unless files_folders.any? { |path| File.exist?(path) }
        raise ArgumentError, 'Neither of provided files or folders exists.'
      end

      find_str = Regexp.new(find_str.sub(%r{^/}, '').sub(%r{/$}, ''))
      paths = get_paths(replace_mode, files_folders)

      puts "Find pattern `#{find_str.source}` in names and replace it with `#{replace_str}`."
      rename_files(paths, dry_run) do |curr_path, _|
        curr_name = curr_path.basename.to_s
        curr_name.gsub(find_str, replace_str)
      end
    end

    # Contains logic of regex_replace CLI command.
    # Matches a given regex in names of given files and/or folders and replaces it using another regex.
    # @param prepend [String] - a text to prepend to filenames of the given files and/or folders
    # @param append [String] - a text to append to filenames of the given files and/or folders
    # @param dry_run [boolean] - true <=> we want to print out what would happen without making changes in the file_system
    # @param replace_mode [ReplaceMode] - tells the system whether file names, directory names or all given names should be changed
    # @param files_folders [Array<String>] - an array of all files and/or folders to be renamed
    def add_text(prepend, append, dry_run, replace_mode, files_folders)
      raise ArgumentError, 'No files or folders provided for renaming.' if files_folders.empty?
      raise ArgumentError, 'Neither --prepend or --append provided.' if prepend.nil? && append.nil?
      unless files_folders.any? { |path| File.exist?(path) }
        raise ArgumentError, 'Neither of provided files or folders exists.'
      end

      prepend = prepend.nil? ? '' : prepend
      append = append.nil? ? '' : append
      paths = get_paths(replace_mode, files_folders)

      if !prepend.empty? && !append.empty?
        puts "Prepend text `#{prepend}` and append text `#{append}`."
      elsif !prepend.empty?
        puts "Prepend text `#{prepend}`."
      elsif !append.empty?
        puts "Append text `#{append}`."
      end

      rename_files(paths, dry_run) do |curr_path, _|
        curr_extname = curr_path.extname.to_s
        curr_name = curr_path.basename.to_s.sub(curr_extname, '')
        "#{prepend}#{curr_name}#{append}#{curr_extname}"
      end
    end

    # Contains logic of regex_replace CLI command.
    # Matches a given regex in names of given files and/or folders and replaces it using another regex.
    # @param file_format [String] - a text to prepend to filenames of the given files and/or folders
    # @param folder_format [String] - a text to append to filenames of the given files and/or folders
    # @param file_initial_num [Integer] - an initial number for files
    # @param folder_initial_num [Integer] - a text to append to filenames of the given files and/or folders
    # @param dry_run [boolean] - true <=> we want to print out what would happen without making changes in the file_system
    # @param replace_mode [ReplaceMode] - tells the system whether file names, directory names or all given names should be changed
    # @param files_folders [Array<String>] - an array of all files and/or folders to be renamed
    def format(file_format, dir_format, file_initial_num, dir_initial_num, dry_run, replace_mode, files_folders)
      raise ArgumentError, 'No files or folders provided for renaming.' if files_folders.empty?
      unless files_folders.any? { |path| File.exist?(path) }
        raise ArgumentError, 'Neither of provided files or folders exists.'
      end

      paths = get_paths(replace_mode, files_folders)

      # Check if file and folder format vars contain NUM_LOCATOR
      file_format = NUM_LOCATOR if file_format.empty? || file_format.nil?
      file_format = "#{file_format}#{NUM_LOCATOR}" unless file_format.include? NUM_LOCATOR
      dir_format = NUM_LOCATOR if dir_format.empty? || dir_format.nil?
      dir_format = "#{dir_format}#{NUM_LOCATOR}" unless dir_format.include? NUM_LOCATOR

      paths_hash = {}

      rename_files(paths, dry_run) do |curr_path, _global_index|
        parent_dir = curr_path.dirname

        # Get right format and initial index
        if curr_path.file?
          curr_format = file_format
          curr_index = file_initial_num
        else
          curr_format = dir_format
          curr_index = dir_initial_num
        end

        # Check if we already visited current dir
        if paths_hash.include? parent_dir
          curr_index = paths_hash[parent_dir]
          paths_hash[parent_dir] += 1
        else
          paths_hash[parent_dir] = curr_index + 1
        end

        # return formatted name
        curr_format.gsub(NUM_LOCATOR, curr_index.to_s)
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
    # @yieldreturn [optional, types, ...] a new name for the currently selected file.
    def rename_files(paths, dry_run)
      raise ArgumentError, "Method `#{__method__}` needs to have a block for renaming files." unless block_given?

      if dry_run
        # Only print
        pathnames_set = Set.new
        paths.each_with_index do |path, index|
          parent_folder = path.dirname
          curr_name = path.basename.to_s
          new_name = yield(path, index)
          new_path = parent_folder + new_name
          if curr_name == new_name
            # Pattern not found in the current name. Do not rename
            puts "Provided pattern would have no effect on `#{curr_name}` [#{path}]"
          elsif new_name.empty?
            puts "Wouldn`t rename `#{curr_name}` -> `#{new_name}` [#{path}]"
          elsif new_path.exist? || pathnames_set.include?(new_path)
            puts "Wouldn`t rename `#{curr_name}` -> `#{new_name}` since it already exists. [#{path}]"
          else
            # Would rename file
            pathnames_set.add(new_path)
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
