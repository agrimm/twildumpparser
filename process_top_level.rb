#!/usr/bin/ruby -Ku

#general handling routine
#the user should call this, rather than process_redirect_sql.rb or the like

require 'processing_shared_library'
require 'process_page_sql'
require 'process_redirect_sql'
require 'process_remove_last_comma'

class ProcessTopLevel
  def main_method(repository_creation_filename, input_filenames)
    input_filenames.each do |input_file_name|
      md = %r{(\w*)wiki-(\d*)-(page|redirect)\.sql}.match(input_file_name)
      raise "Failed to parse #{input_file_name}" if md.nil?
      language_code = md[1]
      datestamp = md[2]
      table_type = md[3]
      repository_id = ProcessingSharedLibrary.new.find_or_add_repository(repository_creation_filename, language_code)
      #puts "Processing #{input_file_name} at\t\t\t#{Time.now.strftime("%H:%M:%S")}"
      almost_processed_file_name = "#{language_code}wiki-#{datestamp}-#{table_type}-almost-processed.sql"
      fully_processed_file_name = "#{language_code}wiki-#{datestamp}-#{table_type}-fully-processed.sql"
      File.delete(almost_processed_file_name) if File.exists?(almost_processed_file_name)

      File.open(input_file_name) do |input_file|
        File.open(almost_processed_file_name, "w") do |almost_processed_file|
          if table_type == "redirect"
            parser_object = ProcessRedirectSql.new
            maximum_repository_statements = 10000
            parser_object.main_method(repository_id, maximum_repository_statements, input_file, almost_processed_file)
          else
            parser_object = ProcessPageSql.new
            parser_object.main_method(repository_id, input_file, almost_processed_file)
          end
        end
      end

      File.open(almost_processed_file_name) do |almost_processed_file|
        File.open(fully_processed_file_name, "w") do |fully_processed_file|
          parser_object = ProcessRemoveLastComma.new
          parser_object.main_method(almost_processed_file, fully_processed_file)
        end
      end
    end
  end
end

if $0 == __FILE__
  input_filenames = ARGV.dup
  ProcessTopLevel.new.main_method("repository_creation.sql", input_filenames)
end

