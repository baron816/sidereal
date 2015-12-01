class Topic < ActiveRecord::Base
  belongs_to :group
  has_many :messages, as: :messageable
  has_many :notifications, as: :notifiable
  delegate :names_data, :users, to: :group
  delegate :includes_user?, to: :group, prefix: true

  validates_presence_of :name
end
