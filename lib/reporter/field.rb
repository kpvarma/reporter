module Reporter
  class Field
    
    attr_accessor :name, :heading, :display, :datatype, :select, :function_name, :link, :remote
    
    # Reporter::Field.new "r_student_register_id", :heading=>"Student ID", :select=>"CONCAT('STD2001',1000 + students.id)", :link=>"get_student_page_link"
    
    def initialize(name, args=[])
      self.name = name
      self.heading = name
      self.display = true
      self.remote = false
      self.datatype = :string
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
    
    def select_query
      self.select.blank? ? nil : "#{self.select} AS #{self.name}"
    end
      
  end
end