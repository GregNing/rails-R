class Admin::EventsController < AdminController

  def index
    @events = Event.all
  end

  def show
    @event = Event.find_by_friendly_id!(params[:id])
  end

  def new
    @event = Event.new
    @event.tickets.build
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

  protected

  def event_params
    # params.require(:event).permit(:name, :description, :friendly_id)
    # params.require(:event).permit(:name, :description, :friendly_id, :status)
    #params.require(:event).permit(:name, :description, :friendly_id, :status, :category_id)
    #这里 @event.tickets.build 两次，等会表单中就有两笔空的 Ticket 可以编辑。
    #Strong Parameters 的部分，新增了 tickets_attributes 数组包含要修改的 
    #ticket 属性，并且额外多了一个 :id 和 :_destroy 是为了配合 accepts_nested_attributes_for 可以编辑和删除。
    params.require(:event).permit(:name, :description, :friendly_id, :status, :category_id, :tickets_attributes => [:id, :name, :description, :price, :_destroy])
  end

end
