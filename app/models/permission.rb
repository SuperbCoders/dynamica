class Permission < ActiveRecord::Base
  include PermissionBase

  belongs_to :user

  validates :project, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true
  validate :validate_owner_should_be_able_to_manage_project

  private

    # Owner should be always able to manage project
    def validate_owner_should_be_able_to_manage_project
      errors.add(:base, :owner_should_be_able_to_manage_project) if project && user_id == project.user_id && !manage?
    end
end
