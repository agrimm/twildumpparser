#!/usr/bin/ruby -Ku

$KCODE = 'utf8' #Probably redundant
require 'jcode' #http://www.fngtps.com/sections/Unicode
require 'processing_shared_library'

class ProcessPageSql

  def detect_fields(input_file)
    processing_shared_library_object = ProcessingSharedLibrary.new

    int = processing_shared_library_object.int
    varchar = processing_shared_library_object.varchar
    double = processing_shared_library_object.double

    autodetected_fields = []

    while line = input_file.gets
      break if line.include?("TYPE=")
      if line =~ /` (bit|bool|smallint|mediumint|int|integer|bigint|tinyint)/
        autodetected_fields << int
      end
      if line =~ /` (float|double|decimal|dec)/
        autodetected_fields << double
      end
      if line =~ /` (varchar|char|binary|varbinary|text|blob|tinytext|tinyblob|mediumtext|mediumblob|longtext|longblob|enum)/
        autodetected_fields << varchar
      end
      #Don't print the line
    end
    autodetected_fields
  end



  def main_method(repository_id, input_file, output_file)
    processing_shared_library_object = ProcessingSharedLibrary.new

    processing_shared_library_object.process_part_before_drop_table(input_file, output_file)

    fields = detect_fields(input_file)

    record = '\\((' + fields.join( '),(' ) + ')\\)'
    while line = input_file.gets
      #id, uri, title, repository_id, local_id
      #Replace with (NULL, NULL, third field with underscores removed, fixed repository id, first field
      line.gsub!(/#{record}(,|;)/) do
        if fields.size == 12
          ending = $13
        elsif fields.size == 11
          ending = $12
        #else
        #  raise "Can't happen"
        end
        namespace = Integer($2)
        if namespace == 0
          '(NULL,NULL,' + $3.tr('_',' ') + ",#{repository_id}," + $1 + ',now(),now())' + ending
        else
          if ending == ";"
            ending
          end
        end
      end
      line.gsub!(/INSERT INTO `page` VALUES/, 'INSERT INTO `articles` (id, uri, title, repository_id, local_id, created_at, updated_at) VALUES')
      line.gsub!(/LOCK TABLES `page` WRITE;/, 'LOCK TABLES `articles` WRITE;')
      line.gsub!(/ALTER TABLE `page`/, 'ALTER TABLE `articles`')
      output_file.print line
    end
  end
end

if $0 == __FILE__
  repository_id = Integer(ARGV.shift)
  input_file = STDIN
  output_file = STDOUT
  ProcessPageSql.new.main_method(repository_id, input_file, output_file)
end
