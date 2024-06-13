# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'PassiveColumns' do
  ActiveRecord::Base.logger = Logger.new($stdout) if defined?(ActiveRecord::Base)

  describe '#initialize' do
    context 'when symbolized hash is passed' do
      subject {}

      it('assigns attributes') do
        user = User.create!(email: 'jello@jello.com', default_project_id: nil)
        project = user.projects.create!(name: 'Project 1', description: 'asd', guidelines: 'GGuidelines')

        user.update!(default_project_id: project.id)
        user.reload

        # Project.all.load
        # user.default_project.attributes.keys

        expect(user.id).to eq(project.user_id)
        expect(user.projects.to_a[0].attributes.keys).to eq(%w[id name])
        # expect(user.default_project.attributes.keys).to eq(%w[id name])
      end
    end
  end
end
