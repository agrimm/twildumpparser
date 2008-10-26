#!/usr/bin/ruby -Ku

$KCODE = 'utf8' #Probably redundant
require 'jcode' #http://www.fngtps.com/sections/Unicode

while line = gets
  line.gsub!(/,;/,";")
  line.gsub!(/INSERT INTO [^)(]* \([^)(]*\) VALUES (;|\n)/,"")
  print line
end

