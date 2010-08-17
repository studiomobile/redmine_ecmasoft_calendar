module Ecmasoft
  module Settings
    def self.group
      Group.find_by_lastname Setting.plugin_ecmasoft_calendar['group_name']
    end

    def self.manager_role
      Role.find_by_name Setting.plugin_ecmasoft_calendar['manager_role']
    end
  end
end