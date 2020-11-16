# frozen_string_literal: true

# An enum for replacement modes
class ReplaceModes
  FILES_ONLY = 'FILES_ONLY'
  FOLDERS_ONLY = 'FOLDERS_ONLY'
  ALL = 'ALL'

  def self.all_values
    [FILES_ONLY, FOLDERS_ONLY, ALL].freeze
  end
end
