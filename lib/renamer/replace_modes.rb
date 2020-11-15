# frozen_string_literal: true

# An enum for replacement modes
class ReplaceModes
  FILES_ONLY = 'FILES_ONLY'.freeze
  FOLDERS_ONLY = 'FOLDERS_ONLY'.freeze
  ALL = 'ALL'.freeze

  def self.all_values
    [FILES_ONLY, FOLDERS_ONLY, ALL].freeze
  end
end
