#!/usr/bin/ruby -Ku

$KCODE = 'utf8' #Probably redundant
require 'jcode' #http://www.fngtps.com/sections/Unicode
require 'processing_shared_library'

class ProcessRedirectSql
  def main_method(repository_id, maximum_repository_statements)
    processing_shared_library_object = ProcessingSharedLibrary.new
    int = processing_shared_library_object.int
    varchar = processing_shared_library_object.varchar
    double = processing_shared_library_object.double
    comma = processing_shared_library_object.comma

    fields = [int, int, varchar] #rd_from, rd_namespace, rd_title
    record = '\\((' + fields.join( '),(' ) + ')\\)'

    while line = gets
      raise "Problem" if line =~ /INSERT INTO/i
      break if line =~ /DROP TABLE/i
      print line
    end

    while line = gets
      break if line.include?("TYPE=")
      #Don't print the line
    end

    repository_statements_size = 1

    while line = gets
      #Replace with (repository_id, first field, third field, now(), now())
      line.gsub!(/#{record}(,|;)/) do |s|
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
      print line
    end
  end
end

repository_id = Integer(ARGV.shift)
maximum_repository_statements = Integer(ARGV.shift)

ProcessRedirectSql.new.main_method(repository_id, maximum_repository_statements)

