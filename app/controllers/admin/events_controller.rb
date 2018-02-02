class Admin::EventsController < AdminController

  def index
    @events = Event.rank(:row_order).all
  end

  def show
    @event = Event.find_by_friendly_id!(params[:id])
    colors = ['rgba(255, 99, 132, 0.2)',
              'rgba(54, 162, 235, 0.2)',
              'rgba(255, 206, 86, 0.2)',
              'rgba(75, 192, 192, 0.2)',
              'rgba(153, 102, 255, 0.2)',
              'rgba(255, 159, 64, 0.2)'
              ]

    ticket_names = @event.tickets.map { |t| t.name }
    status_colors = { "confirmed" => "#FF6384",
                      "pending" => "#36A2EB"}

     @data1 = {
         labels: ticket_names,
         #datasets 参数其实就是资料集的数组，本来只有一个资料集，
         #现在改成透过 Registration::STATUS.map 产生两个资料集，分别是报名未完成和报名成功。
         datasets: Registration::STATUS.map do |s|
           {
             label: I18n.t(s, :scope => "registration.status"),
             data: @event.tickets.map{ |t| t.registrations.by_status(s).count },
             backgroundColor: status_colors[s],
             borderWidth: 1
           }
         end
     }

     @data2 = {
         labels: ticket_names,
         datasets: [{
             label: '# of Amount',
             data:  @event.tickets.map{ |t| t.registrations.by_status("confirmed").count * t.price },
             backgroundColor: colors,
             borderWidth: 1
         }]
     }

   if @event.registrations.any?
     dates = (@event.registrations.order("id ASC").first.created_at.to_date..Date.today).to_a

     @data3 = {
       labels: dates,
       datasets: Registration::STATUS.map do |s|
         {
           :label => I18n.t(s, :scope => "registration.status"),
           :data => dates.map{ |d|
             @event.registrations.by_status(s).where( "created_at >= ? AND created_at <= ?", d.beginning_of_day, d.end_of_day).count
           },
           borderColor: status_colors[s]
         }
       end
     }
   end
  end

  def new
    @event = Event.new
    @event.tickets.build
    @event.attachments.build
    #@event.tickets.build
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to admin_events_path
    else
      render "new"
    end
  end

  def edit
    @event = Event.find_by_friendly_id!(params[:id])
    @event.tickets.build if @event.tickets.empty?
    @event.attachments.build if @event.attachments.empty?
    #@event.tickets.build
  end

  def update
    @event = Event.find_by_friendly_id!(params[:id])

    if @event.update(event_params)
      redirect_to admin_events_path
    else
      render "edit"
    end
  end

  def destroy
    @event = Event.find_by_friendly_id!(params[:id])
    @event.destroy

    redirect_to admin_events_path
  end
  #Pro Tip 小技巧：关于 Array(params[:ids] 这个用法，
  #如果是 Array([1,2,3]) 会等同于 [1,2,3] 没变，
  #但是 Array[nil] 会变成 [] 空数组，这可以让 .each 方法不会因为 nil.each 
  #而爆错。如果不这样处理，在没有勾选任何活动就送出的情况，
  #就会爆出 NoMethodError 错误。除非你额外检查 params[:id] 
  #如果是 nil 就返回，但不如用 Array 来的精巧。
  def bulk_update
    total = 0
    Array(params[:ids]).each do |event_id|
      event = Event.find(event_id)
      # event.destroy
      # total += 1
      if params[:commit] == I18n.t(:bulk_update)
        event.status = params[:event_status]
        if event.save
          total += 1
        end        
      elsif params[:commit] == I18n.t(:bulk_delete)
        event.destroy
        total += 1
      end
    end

    flash[:alert] = "成功完成 #{total} 筆"
    redirect_to admin_events_path
  end

 def reorder
   @event = Event.find_by_friendly_id!(params[:id])
   @event.row_order_position = params[:position]
   @event.save!
   #respond_to 可以让 Rails 根据 request 请求的格式
   #(在 $ajax 中我们有指定了 dataType 是 json)，来回传不同格式
   respond_to do |format|
     format.html { redirect_to admin_events_path }
     format.json { render :json => { :message => "ok" }}
   end
 end
  protected

  def event_params
    # params.require(:event).permit(:name, :description, :friendly_id)
    # params.require(:event).permit(:name, :description, :friendly_id, :status)
    #params.require(:event).permit(:name, :description, :friendly_id, :status, :category_id)
    #这里 @event.tickets.build 两次，等会表单中就有两笔空的 Ticket 可以编辑。
    #Strong Parameters 的部分，新增了 tickets_attributes 数组包含要修改的 
    #ticket 属性，并且额外多了一个 :id 和 :_destroy 是为了配合 accepts_nested_attributes_for 可以编辑和删除。
    #params.require(:event).permit(:name, :description, :friendly_id, :status, :category_id, :tickets_attributes => [:id, :name, :description, :price, :_destroy])
    #params.require(:event).permit(:name, :logo, :remove_logo, :description, :friendly_id, :status, :category_id, :tickets_attributes => [:id, :name, :description, :price, :_destroy])
    #小心 :images => [] 要放在最后，因为默认的 Hash 哈希参数都是放在参数最后
    #  params.require(:event).permit(:name, :logo, :remove_logo, :remove_images, :description, :friendly_id, :status, :category_id, :images => [], :tickets_attributes => [:id, :name, :description, :price, :_destroy])
     params.require(:event).permit(:name, :logo, :remove_logo, :remove_images, :description, :friendly_id, :status, :category_id, :images => [], :tickets_attributes => [:id, :name, :description, :price, :_destroy], :attachments_attributes => [:id, :attachment, :description, :_destroy])
  end

end
