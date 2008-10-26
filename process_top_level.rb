#!/usr/bin/ruby -Ku

#general handling routine
#the user should call this, rather than process_redirect_sql.rb or the like

#require 'language_code.rb'
require 'processing_shared_library.rb'

class ProcessTopLevel
  def self.main_method
    while input_file_name = ARGV.shift
      #input_file_name = "howiki-20080616-page.sql"
      md = %r{(\w*)wiki-(\d*)-(page|redirect)\.sql}.match(input_file_name)
      raise "Failed to parse #{input_file_name}" if md.nil?
      language_code = md[1]
      datestamp = md[2]
      table_type = md[3]
      repository_id = ProcessingSharedLibrary.find_or_add_repository("repository_creation.sql", language_code)
      if table_type == "redirect"
        script = "./process_redirect_sql.rb"
        repository_id = repository_id.to_s + " 10000"
      else
        script = "./process_page_sql.rb"
      end
      puts "Processing #{input_file_name} at\t\t\t#{Time.now.strftime("%H:%M:%S")}"
      almost_processed_file_name = "#{language_code}wiki-#{datestamp}-#{table_type}-almost-processed.sql"
      fully_processed_file_name = "#{language_code}wiki-#{datestamp}-#{table_type}-fully-processed.sql"
      system("#{script} #{repository_id} #{input_file_name} > #{almost_processed_file_name}") or raise "Error"
      puts "Processing #{almost_processed_file_name} at\t#{Time.now.strftime("%H:%M:%S")}"
      system("./process_remove_last_comma.rb #{almost_processed_file_name} > #{fully_processed_file_name}") or raise "Error"
      puts "Created #{fully_processed_file_name} at\t\t#{Time.now.strftime("%H:%M:%S")}"
    end
  end
end

ProcessTopLevel.main_method
