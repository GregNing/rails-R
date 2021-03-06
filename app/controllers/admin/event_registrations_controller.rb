require 'csv'
class Admin::EventRegistrationsController < AdminController
    before_action :require_editor!
   before_action :find_event

   def index     
    @q = @event.registrations.ransack(params[:q])

    @registrations = @q.result.includes(:ticket).order("id DESC").page(params[:page]) 
    #@registrations = @event.registrations.includes(:ticket).order("id DESC").page(params[:page])
    #输入的是日期，但是数据库中存的是 UTC 时间，因此这里需要调用 beginning_of_day 和 end_of_day 
    #才会转换成正确的时间。例如北京时区的 2017/4/30 这一天，对数据库中存 UTC 时间的字段来说，
    #正确的区间是 2017-04-30 16:00:00 UTC 到 2017-05-01 15:59:59 UTC。
        if params[:registration_id].present?
            @registrations = @registrations.where( :id => params[:registration_id].split(",") )
        end   
    if params[:start_on].present?
        @registrations = @registrations.where( "created_at >= ?", Date.parse(params[:start_on]).beginning_of_day )
    end
        if params[:end_on].present?
        @registrations = @registrations.where( "created_at <= ?", Date.parse(params[:end_on]).end_of_day )
        end

      respond_to do |format|
        format.html
        format.csv {
          @registrations = @registrations.reorder("id ASC")
          csv_string = CSV.generate do |csv|
            csv << ["報名ID", "票種", "姓名", "狀態", "Email", "報名時間"]
            @registrations.each do |r|
              csv << [r.id, r.ticket.name, r.name, t(r.status, :scope => "registration.status"), r.email, r.created_at]
            end
          end
          send_data csv_string, :filename => "#{@event.friendly_id}-registrations-#{Time.now.to_s(:number)}.csv"
        }
        format.xlsx
      end
#      if params[:status].present? && Registration::STATUS.include?(params[:status])
#      @registrations = @registrations.by_status(params[:status])
#      end

#     if params[:ticket_id].present?
#      @registrations = @registrations.by_ticket(params[:ticket_id])
#    end

    end

   def destroy
     @registration = @event.registrations.find_by_uuid(params[:id])
     @registration.destroy

     redirect_to admin_event_registrations_path(@event)
   end

  def import
    csv_string = params[:csv_file].read.force_encoding('utf-8')

    tickets = @event.tickets

    success = 0
    failed_records = []
    #其中 csv_string 就是从上传的档案中读取内容，接着用 CSV.parse 进行解析循环。
    CSV.parse(csv_string) do |row|
      registration = @event.registrations.new( :status => "confirmed",
                                   :ticket => tickets.find{ |t| t.name == row[0] },
                                   :name => row[1],
                                   :email => row[2],
                                   :cellphone => row[3],
                                   :website => row[4],
                                   :bio => row[5],
                                   :created_at => Time.parse(row[6]) )

      if registration.save
        success += 1
      else
        failed_records << [row, registration]
        Rails.logger.info("#{row} ----> #{registration.errors.full_messages}")
      end
    end

    flash[:notice] = "總共匯入 #{success} 筆，失敗 #{failed_records.size} 筆"
    redirect_to admin_event_registrations_path(@event)
  end

   protected

   def find_event
     @event = Event.find_by_friendly_id!(params[:event_id])
   end

   def registration_params
     params.require(:registration).permit(:status, :ticket_id, :name, :email, :cellphone, :website, :bio)
   end

  end