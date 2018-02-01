class Event < ApplicationRecord

   validates_presence_of :name, :friendly_id
#这里不但要检查必填，还检查了必须唯一，而且格式只限小写英数字及横线。
  validates_uniqueness_of :friendly_id
  validates_format_of :friendly_id, :with => /\A[a-z0-9\-]+\z/
#   def to_param
#     "#{self.id}-#{self.name}"
#   end
    #亂數 網址
    def to_param
     self.friendly_id
    end
   def generate_friendly_id
     self.friendly_id ||= SecureRandom.uuid
   end
end
