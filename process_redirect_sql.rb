#!/usr/bin/ruby -Ku

$KCODE = 'utf8' #Probably redundant
require 'jcode' #http://www.fngtps.com/sections/Unicode
require 'processing_shared_library'

class ProcessRedirectSql
  def main_method(repository_id, maximum_repository_statements, input_file, output_file)
    raise if maximum_repository_statements < 0
    raise if repository_id < 0

    processing_shared_library_object = ProcessingSharedLibrary.new

    int = processing_shared_library_object.int
    varchar = processing_shared_library_object.varchar

    fields = [int, int, varchar] #rd_from, rd_namespace, rd_title
    record = '\\((' + fields.join( '),(' ) + ')\\)'

    processing_shared_library_object.process_part_before_drop_table(input_file, output_file)

    while line = input_file.gets
      break if line.include?("TYPE=")
      #Don't print the line
    end

    repository_statements_size = 1

    while line = input_file.gets
      #Replace with (repository_id, first field, third field, now(), now())
      line.gsub!(/#{record}(,|;)/) do
        namespace = Integer($2)
        if namespace == 0
          if repository_statements_size != maximum_repository_statements
            repository_statements_size += 1
            '(' + repository_id.to_s + ',' + $1 + ',' + $3.tr('_',' ') + ',now(),now())'+$4
          else
            repository_statements_size = 1
            '(' + repository_id.to_s + ',' + $1 + ',' + $3.tr('_',' ') + ",now(),now());\nINSERT INTO `redirects` (redirect_source_repository_id, redirect_source_local_id, redirect_target_title, created_at, updated_at) VALUES "
          end
        else
          if $4 == ";"
            $4
          end
        end
      end
      line.gsub!(/INSERT INTO `redirect` VALUES/, 'INSERT INTO `redirects` (redirect_source_repository_id, redirect_source_local_id, redirect_target_title, created_at, updated_at) VALUES')
      line.gsub!(/LOCK TABLES `redirect` WRITE;/, 'LOCK TABLES `redirects` WRITE;')
      line.gsub!(/ALTER TABLE `redirect`/, 'ALTER TABLE `redirects`')
      output_file.print line
    end
  end
end

if $0 == __FILE__
  repository_id = Integer(ARGV.shift)
  maximum_repository_statements = Integer(ARGV.shift)
  input_file = STDIN
  output_file = STDOUT
  ProcessRedirectSql.new.main_method(repository_id, maximum_repository_statements, input_file, output_file)
end

