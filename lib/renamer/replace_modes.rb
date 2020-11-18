# frozen_string_literal: true

# An enum for replacement modes
class ReplaceModes
  # Commands using this mode are going to rename only files
  FILES_ONLY = 'FILES_ONLY'
  # Commands using this mode are going to rename only folders
  FOLDERS_ONLY = 'FOLDERS_ONLY'
  # Commands using this mode are going to rename files and folders
  ALL = 'ALL'

  # @return [Array<String>] All values of this enum.
  def self.all_values
    [FILES_ONLY, FOLDERS_ONLY, ALL].freeze
  end
end
