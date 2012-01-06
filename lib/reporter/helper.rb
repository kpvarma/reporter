module Reporter
  module Helper
    def temp
      # <table border="1">
      #         <thead>
      #           <tr>
      #             <th>Month</th>
      #             <th>Savings</th>
      #           </tr>
      #         </thead>
      #         <tfoot>
      #           <tr>
      #             <td>Sum</td>
      #             <td>$180</td>
      #           </tr>
      #         </tfoot>
      #         <tbody>
      #           <tr>
      #             <td>January</td>
      #             <td>$100</td>
      #           </tr>
      #           <tr>
      #             <td>February</td>
      #             <td>$80</td>
      #           </tr>
      #         </tbody>
      #       </table>
    end
    
    def render_report(result, options={})
      render_table(result, options={})
    end
    
    def render_gtable(result, options={})
      jscript_code = ""
      jscript_code = jscript_code + "<script type='text/javascript' src='https://www.google.com/jsapi'></script>"
      jscript_code = jscript_code + "<script type='text/javascript'>"
      jscript_code = jscript_code + "google.load('visualization', '1', {packages:['table']});"
      jscript_code = jscript_code + "google.setOnLoadCallback(drawTable);"
      jscript_code = jscript_code + "function drawTable() {"
        
        report = result.report
        results = result.results
        hsh = report.hsh(results)
        
        jscript_code = jscript_code + "var data = new google.visualization.DataTable();"
        
        ## Generate code to addColumn
        hsh[:cols].each do |heading|
          jscript_code = jscript_code + "data.addColumn('#{heading[:type]}', '#{heading[:label]}');"
        end

        ## Generate code to addRows
        jscript_code = jscript_code + "data.addRows(#{hsh[:rows].count});"
        
        ## Generate code to setCell
        hsh[:rows].each_with_index do |item,x|
          row = item[:c]
          row.each_with_index do |column,y|
            puts "-"*100
            puts "#{hsh[:cols][y][:type]}".blue
            puts "#{column[:v]}, #{column[:f]}".yellow
            if ["date", "boolean"].include?(hsh[:cols][y][:type].to_s)
              puts "Eureeka! Its a date".green
              jscript_code = jscript_code + "data.setCell(#{x}, #{y}, #{column[:v]}, '#{column[:f]}');"
            else
              puts "No luck! Its a ".red
              jscript_code = jscript_code + "data.setCell(#{x}, #{y}, '#{column[:v]}', '#{column[:f]}');"
            end
          end
        end
        
        ## Generating timestamp to create unique div elements
        timestmp = Time.now.to_i
        jscript_code = jscript_code + "var table = new google.visualization.Table(document.getElementById('div_reporter_gtable_#{timestmp}'));"
        jscript_code = jscript_code + "table.draw(data, {showRowNumber: true});"
        
      jscript_code = jscript_code + "}"
      jscript_code = jscript_code + "</script>"
      
      ## Generating code to define the container with a unique name
      jscript_code = jscript_code + "<div id='div_reporter_gtable_#{timestmp}'></div>"
      return jscript_code
    end
    
    def render_table(result, options={})
      
      report = result.report
      results = result.results
      hsh = report.hsh(results)
      
      ## Generate thead from the fields headings
      lst_th = []
      hsh[:cols].each do |heading|
        lst_th << sandwich(:th, heading[:label], options[:th])
      end
      tr_content = sandwich(:tr, lst_th.join("\n"), options[:tr])
      thead_content = sandwich(:thead, tr_content, options[:thead])
      
      ## Generate tbody from results
      lst_tr = []
      hsh[:rows].each do |item|
        lst_td = []
        row = item[:c]
        row.each do |column|
          lst_td << sandwich(:td, column[:f], options[:td])
        end
        lst_tr << sandwich(:tr, lst_td.join("\n"), options[:tr])
      end
      tbody_content = sandwich(:tbody, lst_tr.join("\n"), options[:tbody])
      
      table_content = "#{thead_content} \n #{tbody_content}"
      sandwich(:table, table_content, options)
    end
    
    def sandwich(tag_name, content, options={})
      hsh = {:table=>1, :tbody=>2, :thead=>2, :tfoot=>2, :tr=>3, :th=>4, :td=>4}
      # "<#{tag_name} #{helper.send(:tag_options, options, true) if options}>#{content}</#{tag_name}>".html_safe
      "<#{tag_name} #{tag_options(options, true) if options}>#{content}</#{tag_name}>".html_safe
      # "#{'\t'*(hsh[tag_name])}<#{tag_name} #{tag_options(options, true) if options}>#{content}</#{tag_name}>\n".html_safe
    end
    
  end
end