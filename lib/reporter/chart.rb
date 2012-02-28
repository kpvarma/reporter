module Reporter
  class Chart

    attr_accessor :chart_type, :name, :title, :width, :height, :vAxis, :hAxis, :columns, :divid, :class_data, :interval, :frequency, :controller_name, :action_name, :klass

    def initialize(name, args=[])
      self.chart_type = "LineChart"
      self.name = name
      self.title = title
      self.width = 400
      self.height = 500
      self.vAxis = {}
      self.hAxis = {}
      self.columns = []
      self.divid = "chart_div"
      self.class_data = []
      self.interval = 24
      self.frequency = :hour
      self.controller_name = "chart"
      self.action_name = "reload"
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end

    #   c.ctype "LineChart"
    def ctype(type)
      self.chart_type = type
    end
    
    #   c.ctitle "Job Postings Vs Time"
    def ctitle(title)
      self.title = title
    end
    
    #   c.width 400
    def cwidth(width)
      self.width = width
    end
    
    #   c.height 500
    def cheight(height)
      self.height = height
    end
    
    #   c.vAxis :title=> 'Events',  :titleTextStyle=> {:color=> 'blue'}
    def cvAxis(*args)
      hsh = {}
      args[0].each do |k, v|
        hsh[k] = v unless k.blank?
      end
      self.vAxis = hsh
    end
    
    #   c.hAxis :title=> 'Time',  :titleTextStyle=> {:color=> 'red'}
    def chAxis(*args)
      hsh = {}
      args[0].each do |k, v|
        hsh[k] = v unless k.blank?
      end
      self.hAxis = hsh
    end
    
    # c.column "string", "Month"
    # c.column "number", "Premium Jobs"
    # c.column "number", "Standard Jobs"
    # c.column "number", "Candidates"
    # c.column "number", "Premium Candidates"
    # c.column "number", "Privilege Candidates"
    def ccolumn(type, label)
      self.columns << [type, label]
    end
    
    #   c.divid "admin_dashboard_bar_chart"
    def cdivid(divid)
      self.divid = divid
    end
    
    # c.class_data  {:class_name=>"Job", :where=>"premium = true", :field_name=>"created_at"}
    # c.class_data  {:class_name=>"Job", :where=>"premium = false", :field_name=>"created_at"}
    # c.class_data  {:class_name=>"Individual", :where=>"premium = true", :field_name=>"created_at"}
    # c.class_data  {:class_name=>"Individual", :where=>"premium = false", :field_name=>"created_at"}

    def cclass_data(*args)
      hsh = {}
      #puts args.to_s.red
      args[0].each do |k, v|
        #puts "#{k} => #{v}".magenta
        hsh[k] = v unless k.blank?
      end
      self.class_data << hsh
    end
    
    # c.interval 4
    def cinterval(interval)
      self.interval = interval
    end
    
    # c.frequency :month
    def cfrequency(frequency)
      self.frequency = frequency
    end
       
    # c.controller_name "charts"
    def ccontroller_name(controller_name)
      self.controller_name = controller_name
    end
    
    # c.action_name "show"
    def caction_name(action_name)
      self.action_name = action_name
    end
    
    def options
      {:vAxis => self.vAxis, :hAxis => self.hAxis, :width => self.width, :height => self.height}
    end
    
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

    # Sample Json Accepted by Google Chart
    # {
    #       "cols": [
    #             {"id":"","label":"Topping","pattern":"","type":"string"},
    #             {"id":"","label":"Slices","pattern":"","type":"number"}
    #           ],
    #       "rows": [
    #             {"c":[{"v":"Mushrooms","f":null},{"v":3,"f":null}]},
    #             {"c":[{"v":"Onions","f":null},{"v":1,"f":null}]},
    #             {"c":[{"v":"Olives","f":null},{"v":1,"f":null}]},
    #             {"c":[{"v":"Zucchini","f":null},{"v":1,"f":null}]},
    #             {"c":[{"v":"Pepperoni","f":null},{"v":2,"f":null}]}
    #           ]
    #}

    # Example of input data
    # cols = [['string', 'Year'],['number', 'Standard Jobs'],['number', 'Premium jobs'],['number', 'Candidates'],['number', 'Premium Candidates'],['number', 'Privilege Candidates']]
    def self.get_json_cols(cols)
      json_cols = []
      cols.each do |c|
        json_cols << {"id"=>"","label"=>c[1],"pattern"=>"","type"=>c[0]}
      end
      return json_cols
    end

    def self.get_json_rows(interval, conditions, frequency=10)
      rows = self.data(interval, conditions, frequency)
      json_rows = []
      rows.each do |row|
        #json_rows << {"c"=>row.map{|r| {"v"=>r[0],"f"=>nil}  }}
        hsh_x = []
        row.each do |item|
          hsh_x << {"v"=>item,"f"=>nil}
        end
        json_rows << {"c"=> hsh_x}
      end
      return json_rows
    end

    def self.hsh(cols, interval, conditions, frequency=10)
      
      #puts ""
      #puts ""
      #puts "cols : #{cols}".green
      #puts "interval : #{interval}".green
      #puts "conditions : #{conditions}".green
      #puts "frequency : #{frequency}".green
      #puts ""
      #puts ""
      
      json_cols = self.get_json_cols(cols)
      json_rows = self.get_json_rows(interval, conditions, frequency)
      hsh = {"cols" => json_cols, "rows"=>json_rows}
      return hsh
    end

    def self.json(cols, interval, conditions, frequency=10)
      hsh = self.hsh(cols, interval, conditions, frequency)
      return hsh.to_json
    end

    # interval = :year
    # conditions = {"Premium Job"=>{:class_name=>"Job", :where=>"premium = true", :field_name=>"created_at"}, "Standard Job"=>{:class_name=>"Job", :where=>"premium = false", :field_name=>"created_at"}, "Premium Candidates"=>{:class_name=>"Individual", :where=>"premium = true", :field_name=>"created_at"}, "Standard Candidates"=>{:class_name=>"Individual", :where=>"premium = false", :field_name=>"created_at"}}
    # Chart.data(interval, conditions)
    def self.data(interval, conditions, frequency)
      
      #puts "interval : #{interval}".red
      #puts "frequency : #{frequency}".red
      #puts "conditions : #{conditions}".red
      
      item_hsh = {}
      conditions.each do |condition|
        cls = condition[:class_name]
        field_name = condition[:field_name]
        interval_hsh = get_interval_query(field_name, interval)
        
        #puts "interval = #{interval}".red
        #puts "frequency = #{frequency}".red
        #puts "#{frequency}.#{interval}.ago.to_time = #{frequency}.#{interval}.ago.to_time".red
        
        start_time = eval("#{frequency}.#{interval}.ago.to_time")
        today = Date.today
        end_time = Time.utc(today.year,today.month,today.day,23,59,59)
        
        #puts "start_time = " + start_time.to_s.red
        #puts "end_time = " + end_time.to_s.red
        
        #puts "field_name = " + field_name.red
        #puts "interval_hsh = " + interval_hsh.to_s.green
        query = "#{cls}.select(\"#{interval_hsh[:select_interval]}, count(#{field_name}) as cnt\").where(\"#{condition[:where]} AND #{field_name} >= :start_time AND #{field_name} <= :end_time\", {:start_time => start_time, :end_time => end_time}).group(\"#{interval_hsh[:group_interval]}\").order(\"#{interval_hsh[:group_interval]}\")"
        #puts "query = " + query.blue
        items = eval(query)
        arr = items.map{|x| [x.interval_time, x.cnt]}
        hsh = arr.inject(Hash.new {|h,k| h[k]=0}) {|ha,(cat,name)| ha[cat] = name; ha}
        #puts "hsh = " + hsh.to_s.blue
        item_hsh[condition[:name]] = hsh
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
