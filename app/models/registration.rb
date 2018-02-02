class Registration < ApplicationRecord
 #这里设计了 status 状态字段，以及在新建的时候乱数产生一个 UUID 来当作网址 ID。
  STATUS = ["pending", "confirmed"]
  validates_inclusion_of :status, :in => STATUS
  validates_presence_of :status, :ticket_id
    attr_accessor :current_step
    validates_presence_of :name, :email, :cellphone, :if => :should_validate_basic_data?, message: "必填項目"
    validates_presence_of :name, :email, :cellphone, :bio, :if => :should_validate_all_data?, message: "必填項目"
  belongs_to :event
  belongs_to :ticket
  belongs_to :user, :optional => true
  validate :check_event_status, :on => :create
  before_validation :generate_uuid, :on => :create
  scope :by_status, ->(s){ where( :status => s ) }
  scope :by_ticket, ->(t){ where( :ticket_id => t ) }
  def to_param
    self.uuid
  end

  protected

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
  def should_validate_basic_data?
    current_step == 2  # 只有做到第二步需要验证
  end

  def should_validate_all_data?
    current_step == 3 || status == "confirmed"  # 做到第三步，或最后状态是 confirmed 时需要验证
  end
  def check_event_status
    if self.event.status == "draft"
      errors.add(:base, "活動尚未開放報名")
    end
  end
end
#validate 可以增加自定义的资料验证，后面的 
#:on => :create 参数可以指定只有新建才会验证(默认是新建跟修改都会验证)
#验证不通过时，会用errors.add 增加错误讯息，第一个参数是字段名称，
#第二个参数是错误讯息
#因为表单上并没有 event_id 这个输入框，
#所以就算写成 errors.add(:event_id, "活动尚未开放报名") 也没有地方显示出来。
#依照惯例，任何不属于某个字段的错误，我们会放在 :base 上。