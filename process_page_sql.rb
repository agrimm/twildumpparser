#!/usr/bin/ruby -Ku

$KCODE = 'utf8' #Probably redundant
require 'jcode' #http://www.fngtps.com/sections/Unicode

class ProcessPageSql
  def main_method(repository_id)
    int = '\\d*'
    varchar = '\'(?:[^\\\']|\\\\\\\')*\''
    double = '(?:\\d+\\.\\d+|\\d\\.\\d+e\\-\\d+)'
    comma = ','

    autodetected_fields = []

    while line = gets
      raise "Problem" if line =~ /INSERT INTO/i
      break if line =~ /DROP TABLE/i
      print line
    end

    while line = gets
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

    #fields = [int, int, varchar, varchar, int, int, int, double, varchar, int, int] #For enwiki
    fields = [int, int, varchar, varchar, int, int, int, double, varchar, int, int, int] #For kuwiki

    unless autodetected_fields == [int, int, varchar, varchar, int, int, int, double, varchar, int, int] or autodetected_fields == [int, int, varchar, varchar, int, int, int, double, varchar, int, int, int]
      raise "Mismatch between #{autodetected_fields.join", "} and both #{[int, int, varchar, varchar, int, int, int, double, varchar, int, int].join", "} and #{[int, int, varchar, varchar, int, int, int, double, varchar, int, int, int].join", "}"
    end
    fields = autodetected_fields

    record = '\\((' + fields.join( '),(' ) + ')\\)'
    while line = gets
      #id, uri, title, repository_id, local_id
      #Replace with (NULL, NULL, third field with underscores removed, fixed repository id, first field
      line.gsub!(/#{record}(,|;)/) do |s|
        if fields.size == 12
          ending = $13
        elsif fields.size == 11
          ending = $12
        else
          raise "Can't happen"
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
      print line
    end
  end
end

repository_id = Integer(ARGV.shift)

ProcessPageSql.new.main_method(repository_id)

