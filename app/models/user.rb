class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :memberships
  has_one :profile
  #Rails 的 accepts_nested_attributes_for 作用是可以在更新 User 时，
  #也顺便可以更新 Profile 资料。
  accepts_nested_attributes_for :profile
  has_many :groups, :through => :memberships
  has_many :registrations
  def display_name
    self.email.split("@").first
  end
  ROLES = ["admin", "editor"]
  def is_admin?
    self.role == "admin"
  end

  def is_editor?
    ["admin", "editor"].include?(self.role)  # 如果是 admin 的话，当然也有 editor 的权限
  end
end
