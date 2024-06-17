# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'PassiveColumns' do
  ActiveRecord::Base.logger = Logger.new($stdout) if defined?(ActiveRecord::Base)

  let(:user) { User.create!(email: 'jello@jello.com', default_project_id: nil) }

  context 'when passive columns are declared' do
    it 'retrieves columns except passive ones' do
      Project.create!(
        user_id: user.id,
        name: 'Project 1',
        description: 'a little description',
        guidelines: 'GGuidelines'
      )
      expect(user.projects.to_a[0].attributes.keys).to match_array(%w[id name user_id])
    end

    it 'retrieves columns other than passive ones declared in the child model' do
      ProjectWithPassiveDescription.create!(
        user_id: user.id,
        name: 'Project 1',
        description: 'a little description',
        guidelines: 'GGuidelines'
      )

      expect(user.projects_with_passive_description.count).to eq 1
      expect(user.projects_with_passive_description.take.attributes.keys).to match_array(%w[id name user_id guidelines])
    end
  end
end
