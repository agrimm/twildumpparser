#!/usr/bin/ruby -Ku

class ProcessAph

  def self.do_analysis(input_filename, output_filename)
    input_lines = IO.readlines(input_filename).grep(/../)
    article_details = input_lines.map do |input_line|
      components = input_line.split("\t")
      article_title = components[0]
      uri = components[1]
      {:article_title=>article_title, :uri=>uri}
    end
    i = 1
    sql_portions = article_details.map do |article_detail|
      uri = article_detail[:uri]
      article_title = article_detail[:article_title]
      article_title.gsub!(/'/) {'\\\''}
      sql_portion = "(NULL,'#{uri}','#{article_title}',1001,#{i},now(),now())"
      i += 1
      sql_portion
    end
    sql_statement = "INSERT INTO `articles` (id, uri, title, repository_id, local_id, created_at, updated_at) VALUES " + sql_portions.join(",") + ";\n\n"
    File.open(output_filename, "w") do |f|
      f.print(sql_statement)
    end
  end

end

if __FILE__ == $0
  unless ARGV.size == 2
    raise "Wrong number of arguments!"
  else
    ProcessAph.do_analysis(ARGV[0], ARGV[1])
  end
end

