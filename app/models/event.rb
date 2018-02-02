class Event < ApplicationRecord
  include RankedModel
  mount_uploader :logo, EventLogoUploader  
  mount_uploaders :images, EventImageUploader
  serialize :images, JSON
  ranks :row_order
  STATUS = ["draft", "public", "private"]
    belongs_to :category, :optional => true
    #某些版本的Rails 有个accepts_nested_attributes_for 的bug 
    #让has_many 故障了，需要额外补上inverse_of 参数，不然存储时会找不到tickets
    has_many :tickets, :dependent => :destroy, :inverse_of  => :event
    accepts_nested_attributes_for :tickets, :allow_destroy => true, :reject_if => :all_blank
    has_many :attachments, :class_name => "EventAttachment", :dependent => :destroy
    accepts_nested_attributes_for :attachments, :allow_destroy => true, :reject_if => :all_blank
    validates_inclusion_of :status, :in => STATUS
   validates_presence_of :name, :friendly_id
#这里不但要检查必填，还检查了必须唯一，而且格式只限小写英数字及横线。
  validates_uniqueness_of :friendly_id
  validates_format_of :friendly_id, :with => /\A[a-z0-9\-]+\z/
  has_many :registrations, :dependent => :destroy
#   def to_param
#     "#{self.id}-#{self.name}"
#   end
    scope :only_public, -> { where( :status => "public" ) }
    scope :only_available, -> { where( :status => ["public", "private"] ) }
    #亂數 網址
    def to_param
     self.friendly_id
    end
   def generate_friendly_id
     self.friendly_id ||= SecureRandom.uuid
   end  
end
