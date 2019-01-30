require 'rails_helper'

describe 'Merge request > User creates MR' do
  it_behaves_like 'a creatable merge request'

  context 'from a forked project' do
    include ProjectForksHelper

    let(:canonical_project) { create(:project, :public, :repository) }

    let(:source_project) do
      fork_project(canonical_project, user,
        repository: true,
        namespace: user.namespace)
    end

    context 'to canonical project' do
      it_behaves_like 'a creatable merge request'
    end

    context 'to another forked project' do
      let(:target_project) do
        fork_project(canonical_project, user,
          repository: true,
          namespace: user.namespace)
      end

      it_behaves_like 'a creatable merge request'
    end
  end

  context 'source project', :js do
    let(:user) { create(:user) }
    let(:target_project) { create(:project, :public, :repository) }
    let(:source_project) { target_project }

    before do
      source_project.add_maintainer(user)

      sign_in(user)
      visit project_new_merge_request_path(
        target_project,
        merge_request: {
          source_project_id: source_project.id,
          target_project_id: target_project.id
        })
    end

    it 'filters source project' do
      find('.js-source-project').click
      find('.dropdown-source-project input').set('source')

      expect(find('.dropdown-source-project .dropdown-content')).not_to have_content(source_project.name)
    end
  end
end
