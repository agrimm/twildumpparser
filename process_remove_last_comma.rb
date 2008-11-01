#!/usr/bin/ruby -Ku

$KCODE = 'utf8' #Probably redundant
require 'jcode' #http://www.fngtps.com/sections/Unicode

class ProcessRemoveLastComma
  def main_method(input_file, output_file)
    while line = input_file.gets
      line.gsub!(/,;/,";")
      line.gsub!(/INSERT INTO [^)(]* \([^)(]*\) VALUES (;|\n)/,"")
      output_file.print line
    end
  end
end

if $0 == __FILE__
  ProcessRemoveLastComma.new.main_method(STDIN, STDOUT)
end

