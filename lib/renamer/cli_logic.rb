# frozen_string_literal: true

module Renamer
  # Implements logic of the created CLI command.
  class CLI_Logic
    def base_replace(find_str, replace_str, dry_run, dir_focus, files_folders)
      puts find_str
      puts replace_str
      puts dry_run
      puts dir_focus
      puts files_folders
    end
  end
end
