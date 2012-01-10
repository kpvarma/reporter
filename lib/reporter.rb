require "reporter/version"
require "reporter/field"
require "reporter/report"
require "reporter/result"
require "reporter/helper"

module Reporter
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    #report "students_attendence_report" do |r|
    # 
    #   r.rtitle "Student Attendence Report"
    # 
    #   r.rcolumn "r_student_id", :heading=>"Id", :display=>false
    #   r.rcolumn "r_date", :heading=>"Date", :select=>"DATE_FORMAT(DATE_ADD(students.punched_in_at, INTERVAL 5.5 HOUR), '%d %M %Y %H:%i:%s')"
    #   r.rcolumn "r_student_register_id", :heading=>"Student ID", :select=>"CONCAT('STD2001',1000 + students.id)", :link=>"get_student_page_link"
    #   r.rcolumn "r_name", :heading=>"Name", :select=>"name"
    #   r.rcolumn "r_email", :heading=>"Email", :select=>"students.email"
    #   r.rcolumn "r_class_name", :heading=>"", :select=>"students.class_name"
    #   r.rcolumn "r_absent", :heading=>"Absent?", :select=>"CASE WHEN users.absent THEN 'Yes' ELSE 'No' END"
    #   r.rcolumn "r_average", :heading=>"Average", :function_name=>"display_average"
    # 
    # end
    
    def report(*args, &block)
      args.each do |rname|
        #puts "rname ".red + rname.green
        report = Reporter::Report.new(rname)
        yield(report)
        cattr_accessor :reports
        report.klass = self
        if self.reports.blank?
          self.reports = {rname => report}
        else
          self.reports[rname] = report
        end
      end
    end
    
    # Student.fetch()
    
    def fetch(rname, options={})
      report = self.reports[rname]
      results = report.fetch(options)
      result = Reporter::Result.new
      result.report = report
      result.results = results
      return result
    end
    
    def csv(rname, options={})
      report = self.reports[rname]
      csv_string = report.csv(options)
      return csv_string
    end
    
    def hsh(rname, options={})
      report = self.reports[rname]
      hsh_data = report.hsh(options)
      return hsh_data
    end
    
  end
    
end

class ActiveRecord::Base
  include Reporter
end

class ActionView::Base
  include Reporter::Helper
end
