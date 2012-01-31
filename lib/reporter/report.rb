module Reporter
  class Report
    require "csv"
    attr_accessor :name, :title, :fields, :joins, :klass, :select, :where, :order, :group, :having, :per_page, :current_page
    
    # report = Reporter::Report.new(rname)
    
    def initialize(name, args=[])
      self.name = name
      self.title = name
      self.fields = []
      self.joins = []
      self.where = []
      self.select = []
      self.per_page = 100
      self.current_page = 1
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
    
    #   report.rtitle "Student Attendence Report"
    
    def rtitle(title)
      self.title = title
    end
    
    #   report.rcolumn "r_student_id", :heading=>"Id", :display=>false
    #   report.rcolumn "r_date", :heading=>"Date", :select=>"DATE_FORMAT(DATE_ADD(students.punched_in_at, INTERVAL 5.5 HOUR), '%d %M %Y %H:%i:%s')"
    #   report.rcolumn "r_student_register_id", :heading=>"Student ID", :select=>"CONCAT('STD2001',1000 + students.id)", :link=>"get_student_page_link"
    #   report.rcolumn "r_average", :heading=>"Average", :function_name=>"display_average"
    
    def rcolumn(cname, options={} )
      #puts "cname ".red + cname.green
      field = Reporter::Field.new(cname, options)
      self.fields << field
      #options.each do |key, val|
      #  puts "#{key} ".red + val.to_s.green
      #end
    end
    
    def rjoin(*args)
      args.each do |arg|
        self.joins << arg unless arg.blank?
        #puts "joins ".red + arg.to_s.green
      end
    end
    
    def rwhere(*args)
      args.each do |arg|
        self.where << arg unless arg.blank?
        #puts "where ".red + arg.to_s.green
      end
    end
    
    def rorder(value)
      self.order = value
      #puts "order ".red + value.to_s.green
    end
    
    def rgroup(value)
      self.group = value
      #puts "group ".red + value.to_s.green
    end
    
    def rhaving(value)
      self.having = value
      #puts "having ".red + value.to_s.green
    end
    
    def fetch(options=[])
      relation = self.construct(options)
      current_page = 1
      current_page = options[:current_page] if options[:current_page]
      per_page = 25
      per_page = options[:per_page] if options[:per_page]
      relation = relation.page(current_page).per(per_page) 
      return relation
    end
    
    def total_count(options=[])
      relation = self.construct(options)
      return relation.count()
    end
    
    def construct(options={})
      self.select = []
      self.fields.each do |field|
        self.select << field.select_query if field.select_query
      end
      
      order = options[:order] unless options[:order].blank?
      group = self.group || ""
      having = self.having || ""
      
      joins = self.joins
      select_query = self.select.join(", ")
      where_query = where.join(" AND ")
      where_values = {}
      where_values = options[:where] unless options[:where].blank?
      
      hsh_query = {:select=>select_query, :joins=>self.joins, :where=>{:query=>where_query, :values=>where_values}, :order=>order, :group=>group, :having=>having, :per_page=>per_page, :current_page=>current_page}
      hsh_query.delete_if{|k,v| k.blank? || v.blank?}
      
      relation = self.klass.select(hsh_query[:select])
      relation = relation.joins(hsh_query[:joins]) if hsh_query[:joins]
      relation = relation.where(hsh_query[:where][:query], hsh_query[:where][:values]) if hsh_query[:where][:query] and hsh_query[:where][:values]
      relation = relation.order(hsh_query[:order]) if hsh_query[:order]
      relation = relation.group(hsh_query[:group]) if hsh_query[:group]
      relation = relation.having(hsh_query[:having]) if hsh_query[:having]
      return relation
    end
    
    def csv(options={})
      relation = self.construct(options)
      results = relation.all
      
      list = []
      index = 1

      date_header = ["", "Downloaded Date", "#{Date.today.strftime('%d/%m/%Y')}"]
      headings = ["Sl.no"] + self.fields.select{|x| x.display}.collect(&:heading)
      space = [""] * (headings.size + 1)

      list << date_header
      list << space
      list << headings
      list << space

      ## Appending Results
      results.each do |result|
        items_list = []
        items_list << index
        
        self.fields.select{|x| x.display}.each do |field|
          display = ""
          if field.link
            if field.remote
              display = result.try(field.name)
            else
              display = result.try(field.name)
            end
          elsif field.function_name
            display = result.try(field.function_name)
          else
            if field.datatype.to_s == "date"
              date = result.try(field.name)
              display = date.strftime("%B %d, %Y")
            elsif field.datatype.to_s == "boolean"
              value = result.try(field.name)
              display = value.to_s.titleize
            else
              display = result.try(field.name)
            end
          end
          items_list << display
        end
        
        list << items_list
        index = index + 1
      end

      csv_string = CSV.generate do |csv|
        list.each do |l|
          csv << l
        end
      end
      return csv_string
    end
    
    def json(options={})
      results = self.fetch(options)
      hsh(results)
    end
    
    def hsh(results)
      hsh = {}
      hsh[:cols] = []
      hsh[:rows] = []
      self.fields.select{|x| x.display}.each do |field|
        hsh[:cols] << {:id=>field.name,:label=> field.heading,:pattern=>"",:type=>field.datatype}
      end

      results.each do |result|
        row = []
       self.fields.select{|x| x.display}.each do |field|
         fdisplay = ""
          if field.link
            if field.remote
              vdisplay = ActionController::Base.helpers.link_to result.try(field.name), result.try(field.link), :remote=>true, :onclick=>"showLightBoxLoading();"
              fdisplay = result.try(field.name)
            else
              vdisplay = ActionController::Base.helpers.link_to result.try(field.name), result.try(field.link), :target=>"_blank"
              fdisplay = result.try(field.name)
            end
          elsif field.function_name
            vdisplay = result.try(field.function_name)
          else
            if field.datatype.to_s == "date"
              date = result.try(field.name)
              vdisplay = "new Date(#{date.strftime('%Y')},#{date.strftime('%m')},#{date.strftime('%d')})"
              fdisplay = date.strftime("%B %d, %Y")
            elsif field.datatype.to_s == "boolean"
              value = result.try(field.name)
              vdisplay = value.to_s.downcase == "no" ? "false" : "true"
              fdisplay = value.to_s.titleize
            else
              vdisplay = result.try(field.name)
            end
          end
          fdisplay = vdisplay if fdisplay.blank?
          row << {:v=>vdisplay,:f=>fdisplay}
        end
        hsh[:rows] << {:c=>row}
      end
      return hsh
    end
  end
end