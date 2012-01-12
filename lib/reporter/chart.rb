module Reporter
  class Chart

    def self.get_interval_query(field_name, interval)
      if interval.to_s == "hour"
        select_interval = "DATE_FORMAT(#{field_name}, '%d %b, %Y %k:00') as interval_time"
        group_interval = "year(#{field_name}), month(#{field_name}), day(#{field_name}), hour(#{field_name})"
      elsif interval.to_s == "day"
        select_interval = "DATE_FORMAT(#{field_name}, '%d %b, %Y') as interval_time"
        group_interval = "year(#{field_name}), month(#{field_name}), day(#{field_name})"
      elsif interval.to_s == "week"
        select_interval = "DATE_FORMAT(#{field_name}, '%u th week, %Y') as interval_time"
        group_interval = "year(#{field_name}), week(#{field_name})"
      elsif interval.to_s == "month"
        select_interval = "DATE_FORMAT(#{field_name}, '%b, %Y') as interval_time"
        group_interval = "year(#{field_name}), month(#{field_name})"
      elsif interval.to_s == "year"
        select_interval = "DATE_FORMAT(#{field_name}, '%Y') as interval_time"
        group_interval = "year(#{field_name})"
      else
        select_interval = "DATE_FORMAT(#{field_name}, '%b, %Y') as interval_time"
        group_interval = "year(#{field_name}), month(#{field_name})"
      end
      return {:select_interval=>select_interval, :group_interval=>group_interval}
    end

    # interval = :year
    # conditions = {"Premium Job"=>{:class_name=>"Job", :where=>"premium = true", :field_name=>"created_at"}, "Standard Job"=>{:class_name=>"Job", :where=>"premium = false", :field_name=>"created_at"}, "Premium Candidates"=>{:class_name=>"Individual", :where=>"premium = true", :field_name=>"created_at"}, "Standard Candidates"=>{:class_name=>"Individual", :where=>"premium = false", :field_name=>"created_at"}}
    # Chart.data(interval, conditions)
    def self.data(interval, conditions, frequency=10)
      
      item_hsh = {}
      conditions.each do |name, condition|
        cls = condition[:class_name]
        field_name = condition[:field_name]
        interval_hsh = get_interval_query(field_name, interval)
        
        start_date = eval("Time.now - #{frequency}.#{interval}s")
        end_date = Time.now
        
        #puts field_name.red
        #puts interval_hsh.to_s.green
        query = "#{cls}.select(\"#{interval_hsh[:select_interval]}, count(#{field_name}) as cnt\").where(\"#{condition[:where]} AND #{field_name} >= :start_date AND #{field_name} <= :end_date\", {:start_date => start_date, :end_date => end_date}).group(\"#{interval_hsh[:group_interval]}\").order(\"#{interval_hsh[:group_interval]}\")"
        puts query.blue
        items = eval(query)
        arr = items.map{|x| [x.interval_time, x.cnt]}
        hsh = arr.inject(Hash.new {|h,k| h[k]=0}) {|ha,(cat,name)| ha[cat] = name; ha}
        #puts hsh.to_s.blue
        item_hsh[name] = hsh
      end
      
      month_list = []
      item_hsh.each do |name, item|
        month_list = month_list + item.keys
      end
      month_list = month_list.uniq
      
      total_data = []
      month_list.each do |m|
        #puts "*"*100
        #puts "m = #{m}".red
        data = [m]
        item_hsh.each do |name, item|
          if item.has_key?(m)
            data << item[m]
            #puts "item[m] = #{item[m]}".blue
          else
            data << 0
            #puts "item[m] = 0".blue
          end
        end
        total_data << data
      end
      return total_data
      
    end
  end
end
