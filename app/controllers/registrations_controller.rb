class RegistrationsController < ApplicationController
  before_action :find_event

  def new
  end

  def create
    @registration = @event.registrations.new(registration_params)
    #这里针对 ticket 额外用 @event.tickets.find 再检查确定这个票种属于这个活动
    @registration.ticket = @event.tickets.find( params[:registration][:ticket_id] )
    # @registration.status = "confirmed"
     @registration.status = "pending"
    @registration.user = current_user
    @registration.current_step = 1
    if @registration.save
    #   redirect_to event_registration_path(@event, @registration)
      redirect_to step2_event_registration_path(@event, @registration)
    else
    #本来的 flash 搭配的是 redirect，这会在跳转后清空 flash 讯息(所以只会显示一次)。
    #这里因为并不是 redirect 跳转，而是用 render 显示页面，这种情况要改用 flash.now。
        flash.now[:alert] = @registration.errors[:base].join("、")
      render "new"
    end
  end

  def show
    @registration = @event.registrations.find_by_uuid(params[:id])
  end
  def step1
    @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def step1_update
    @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.current_step = 1
    if @registration.update(registration_params)
      redirect_to step2_event_registration_path(@event, @registration)
    else
      render "step1"
    end
  end
  def step2
    @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def step2_update
    @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.current_step = 2
    if @registration.update(registration_params)
      redirect_to step3_event_registration_path(@event, @registration)
    else
      render "step2"
    end
  end
  def step3
    @registration = @event.registrations.find_by_uuid(params[:id])
  end

  def step3_update
    @registration = @event.registrations.find_by_uuid(params[:id])
    @registration.status = "confirmed"
    @registration.current_step = 3
    if @registration.update(registration_params)
      flash[:notice] = "報名成功"
      NotificationMailer.confirmed_registration(@registration).deliver_later
      #以下指令可以在 rails c測試接收報名成功信
      #NotificationMailer.confirmed_registration( Registration.by_status("confirmed").last ).deliver_now
      redirect_to event_registration_path(@event, @registration)
    else
      render "step3"
    end
  end
  protected

  def registration_params
    params.require(:registration).permit(:ticket_id, :name, :email, :cellphone, :website, :bio)
  end

  def find_event
    @event = Event.find_by_friendly_id(params[:event_id])
  end

end
