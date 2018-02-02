module RegistrationsHelper
    #这个 registration_filters 方法的目的，在于建构按钮超连结的参数。
    #当点了状态再点票种，或是点了票种再点状态时，要同时套用两个参数。
   def registration_filters(options)
     params.permit(:status, :ticket_id).merge(options)
   end
end
