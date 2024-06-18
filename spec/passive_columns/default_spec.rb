# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'PassiveColumns' do
  ActiveRecord::Base.logger = Logger.new($stdout) if defined?(ActiveRecord::Base)

  after(:each) do
    Project.delete_all
    User.delete_all
  end

  let(:user) { User.create!(email: 'jello@jello.com', default_project_id: nil) }

  context 'when passive columns are declared' do
    context 'active record relation' do
      it 'retrieves columns except passive ones' do
        Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')
        expect(Project.take.attributes.keys).to match_array(%w[id name user_id])
      end

      it 'preloads the column on demand and caches it into the model' do
        project = Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')
        expect(project.attributes.keys).to match_array(%w[id name user_id guidelines description])

        project.reload
        expect(project.attributes.keys).to match_array(%w[id name user_id])
        expect(project.description).to eq 'a description'
        expect(project.attributes.keys).to match_array(%w[id name user_id description])
      end

      it 'selects without changing the originally selected columns' do
        Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')
        project = Project.select('id', 'name').take!
        expect(project.attributes.keys).to match_array(%w[id name])
        expect(project.guidelines).to eq 'g'

        expect(project.attributes.keys).to match_array(%w[id name guidelines])
      end

      it 'throws an exception when attempting to access a non-passive column' do
        Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')
        project = Project.select('id').take!
        expect(project.attributes.keys).to match_array(%w[id])
        expect { project.name }.to raise_error(ActiveModel::MissingAttributeError)
        expect { project.description }.not_to raise_error
      end

      it 'retrieves columns other than passive ones declared in the child model' do
        ProjectWithPassiveDescription.create!(user_id: user.id, name: 'Project', description: 'd', guidelines: 'g')
        expect(ProjectWithPassiveDescription.take.attributes.keys).to match_array(%w[id name user_id guidelines])
      end

      it 'includes the association and preloads its columns without passive ones' do
        ProjectWithPassiveDescription.create!(user_id: user.id, name: 'Project', description: 'd', guidelines: 'g')
        users = User.includes(:projects_with_passive_description).all
        projects = users[0].projects_with_passive_description
        expect(projects[0].attributes.keys).to match_array(%w[id name user_id guidelines])
      end
    end

    context 'associations' do
      it 'retrieves columns except passive ones' do
        Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'Guidelines')
        expect(user.projects.to_a[0].attributes.keys).to match_array(%w[id name user_id])
      end

      it 'retrieves columns other than passive ones declared in the child model' do
        ProjectWithPassiveDescription.create!(user_id: user.id, name: 'Project', description: 'd', guidelines: 'g')

        expect(user.projects_with_passive_description.count).to eq 1
        expect(user.projects_with_passive_description.take.attributes.keys).to \
          match_array(%w[id name user_id guidelines])
      end
    end

    context 'load_column' do
      it 'loads the column if it is not loaded yet' do
        Project.create!(user_id: user.id, name: 'random', description: 'a description', guidelines: 'Guidelines')

        expect(Project.count).to eq 1
        project = Project.select('id').take!
        expect(project.attributes.keys).to match_array(%w[id])
        expect(project.load_column('name')).to eq 'random'
        expect(project.load_column('user_id')).to eq user.id
        expect(project.load_column('description')).to eq 'a description'
        expect(project.attributes.keys).to match_array(%w[id name user_id description])
      end
    end
  end
end
