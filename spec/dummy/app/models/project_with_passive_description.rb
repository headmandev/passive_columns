# frozen_string_literal: true

class ProjectWithPassiveDescription < Project
  passive_columns :description
end
