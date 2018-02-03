require 'csv'
namespace :dev do
  #產生使用者資訊
  # task :fake => :environment do
  #   User.delete_all
  #   Event.delete_all

  #   users = []
  #   users << User.create!( :email => "admin@example.org", :password => "12345678" )

  #   10.times do |i|
  #     users << User.create!( :email => Faker::Internet.email, :password => "12345678")
  #     puts "Generate User #{i}"
  #   end

  #   20.times do |i|
  #     topic = Event.create!( :name => Faker::Cat.name,
  #                            :description => Faker::Lorem.paragraph,
  #                            :user_id => users.sample.id )
  #     puts "Generate Event #{i}"
  #   end
  # end
  #產生 票數以及註冊資訊
  #  task :fake_event_and_registrations => :environment do
  #    event = Event.create!( :status => "public", :name => "Meetup", :friendly_id => "fullstack-meetup")
  #    t1 = event.tickets.create!( :name => "Guest", :price => 0)
  #    t2 = event.tickets.create!( :name => "VIP 第一期", :price => 199)
  #    t3 = event.tickets.create!( :name => "VIP 第二期", :price => 199)

  #    1000.times do |i|
  #      event.registrations.create!( :status => ["pending", "confirmed"].sample,
  #                                   :ticket => [t1,t2,t3].sample,
  #                                   :name => Faker::Cat.name, :email => Faker::Internet.email,
  #                                   :cellphone => "12345678", :bio => Faker::Lorem.paragraph,
  #                                   :created_at => Time.now - rand(10).days - rand(24).hours )
  #    end

  #    puts "Let's visit http://localhost:3000/admin/events/fullstack-meetup/registrations"
  # end
  #和汇出 CSV 一样，Ruby 内建了 CSV 库可以解析 CSV，所以第一行先 require 'csv'
#CSV.foreach 会打开这个 CSV 档案跑循环，每笔资料就是一行 row，那一行的第一列是 row[0]、第二列是 row[1]。只要依序塞给 event.registrations.new 即可。
#CSV 中的票种是字符串，但是转进我们的数据库中需要转换成 Ticket model，因此这里写成 tickets.find{ |t| t.name == row[0] } 用票种名称去找是哪一个对象。
#时间也是一样，透过 Time.parse 转成时间对象
#因为汇入会一次汇入非常多笔，我们希望不管每笔资料 save 成功或失败，都能跑完全部资料，最后印出一个总结：告诉我们总共几笔成功，总共几笔失败，是哪些笔失败又是什么原因。
  task :import_registration_csv_file => :environment do
    event = Event.find_by_friendly_id("fullstack-meetup")
    tickets = event.tickets
    success = 0
    failed_records = []
    CSV.foreach("#{Rails.root}/tmp/registrations.csv") do |row|
      registration = event.registrations.new( :status => "confirmed",
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
      end
    end
    puts "总共汇入 #{success} 笔，失败 #{failed_records.size} 笔"
    failed_records.each do |record|
      puts "#{record[0]} ---> #{record[1].errors.full_messages}"
    end
  end

end

#account admin@example.org
#pwd 12345678