require 'test/unit'
require 'stringio'
require 'processing_shared_library'

class TestSQLParsing < Test::Unit::TestCase
  def setup
    @program_test_directory = "program_test_data/"
  end

  def test_howiki
    program_test_directory = "program_test_data/"
    comparison_groups = [ 
["original_howiki_redirect.sql", "actual_howiki_redirect.sql", "expected_howiki_redirect.sql", "./process_redirect_sql.rb"], 
["original_howiki_redirect_mod_1.sql", "actual_howiki_redirect.sql", "expected_howiki_redirect.sql", "./process_redirect_sql.rb"], 
["simplified_original_howiki-20080616-page.sql", "actual_howiki_page.sql", "expected_howiki-20080616-page.sql", "./process_page_sql.rb"],
["simplified_original_howiki-20080616-page_mod_1.sql", "actual_howiki_page.sql", "expected_howiki-20080616-page.sql", "./process_page_sql.rb"],
["simplified_original_howiki-20080616-page_mod_2.sql", "actual_howiki_page.sql", "expected_howiki-20080616-page.sql", "./process_page_sql.rb"] ]
    comparison_groups.each do |original_file_name, actual_file_name, expected_file_name, script|
      system("cat #{program_test_directory + original_file_name} | #{script} 3 #{0 if script == "./process_redirect_sql.rb"} | ./process_remove_last_comma.rb > #{program_test_directory + actual_file_name}")
      file1 = File.open("#{program_test_directory + actual_file_name}")
      file2 = File.open("#{program_test_directory + expected_file_name}")
      assert_equal file2.read, file1.read, "Inconsistency between #{actual_file_name} and #{expected_file_name} derived from #{program_test_directory + original_file_name}"
    end
  end

  #Redirects are getting longer, rather than shorter, and are bumping up against the size limit. I could increase the size limit, but I may not be able to do that everywhere
  def test_new_statement_addition
    program_test_directory = "program_test_data/"
    comparison_groups = [
["original_howiki_redirect.sql", "actual_howiki_redirect_with_new_statements.sql", "expected_howiki_redirect_with_new_statements.sql", "./process_redirect_sql.rb", ["3", "1"] ], 
["nomainspace_howiki_redirect.sql", "actual_howiki_redirect_with_nomainspace.sql", "expected_howiki_redirect_with_nomainspace.sql", "./process_redirect_sql.rb", ["3", "1"] ] 
]
    comparison_groups.each do |original_file_name, actual_file_name, expected_file_name, script, options|
      system("cat #{program_test_directory + original_file_name} | #{script} #{options.join(" ")} | ./process_remove_last_comma.rb > #{program_test_directory + actual_file_name}")
      text1 = IO.read("#{program_test_directory + expected_file_name}")
      text2 = IO.read("#{program_test_directory + actual_file_name}")
      assert_equal text1, text2
    end
  end

  def test_repository_searching
    test_repository_fullname = "program_test_data/test_repository_searching_repository.sql"
    test_repository_contents = "insert into `repositories` (id, abbreviation, short_description, created_at, updated_at) VALUES (1,'enwiki','English language wikipedia',now(),now());"
    File.open(test_repository_fullname,"w") do |f|
      f.write(test_repository_contents)
    end
    processing_shared_library_object = ProcessingSharedLibrary.new
    assert_equal 1, processing_shared_library_object.find_repository(test_repository_fullname, "en")
    assert_nil processing_shared_library_object.find_repository(test_repository_fullname, "e")
    assert_nil processing_shared_library_object.find_repository(test_repository_fullname, "enw")
    assert_nil processing_shared_library_object.find_repository(test_repository_fullname, "!")
  end

  def test_repository_listing
    require 'process_top_level'
    #TODO: make testing for multiple repositories
    expected_results = [[1,"enwiki","English language Wikipedia", "now()", "now()"],[2,"arwiki","Arabic language Wikipedia", "now()", "now()"]]
    values = [[1,"'enwiki'","'English language Wikipedia'", "now()", "now()"],[2,"'arwiki'","'Arabic language Wikipedia'", "now()", "now()"]]
    value_strings = values.map {|value| "(" + value.join(",") + ")"}
    all_values_string = value_strings.join(",") + ";"
    string = "insert into `repositories` (id, abbreviation, short_description, created_at, updated_at) VALUES "
    string << all_values_string
    stringio = StringIO.new(string)
    processing_shared_library_object = ProcessingSharedLibrary.new
    results = processing_shared_library_object.list_repositories(stringio)
    assert_equal expected_results, results

    stringio.rewind
    assert processing_shared_library_object.find_unused_repository_id(stringio) == 3
  end

  def test_repository_adding
    require 'process_top_level.rb'
    original_text = "insert into `repositories` (id, abbreviation, short_description, created_at, updated_at) VALUES (1,'enwiki','English language Wikipedia',now(),now());"
    expected_text = "insert into `repositories` (id, abbreviation, short_description, created_at, updated_at) VALUES (1,'enwiki','English language Wikipedia',now(),now()),(2,'arwiki','Arabic language Wikipedia',now(),now());" 
    full_filename = "program_test_data/test_adding_repository.sql"
    File.delete(full_filename) if File.exists?(full_filename)
    File.open(full_filename, "w") do |f|
      f.write(original_text)
    end
    processing_shared_library_object = ProcessingSharedLibrary.new
    assert_equal 2, processing_shared_library_object.add_repository(full_filename, "ar")
    assert_raise (RuntimeError) {processing_shared_library_object.add_repository(full_filename, "en")}
    assert_raise (RuntimeError) {processing_shared_library_object.add_repository(full_filename, "!")}
    assert_raise (RuntimeError) {processing_shared_library_object.add_repository(full_filename, "ar")}
    assert_equal expected_text, IO.read(full_filename)
  end

  def test_repository_adding
    require 'process_top_level.rb'
    #original_text = "insert into `repositories` (id, abbreviation, short_description, created_at, updated_at) VALUES ;"
    original_text = ""
    expected_text = "insert into `repositories` (id, abbreviation, short_description, created_at, updated_at) VALUES (1,'enwiki','English language Wikipedia',now(),now()),(2,'arwiki','Arabic language Wikipedia',now(),now());" 
    full_filename = "program_test_data/test_adding_repository.sql"
    File.delete(full_filename) if File.exists?(full_filename)
    File.open(full_filename, "w") do |f|
      f.write(original_text)
    end
    processing_shared_library_object = ProcessingSharedLibrary.new
    assert_equal 1, processing_shared_library_object.find_or_add_repository(full_filename, "en")
    assert_equal 1, processing_shared_library_object.find_repository(full_filename, "en")
    assert_equal 1, processing_shared_library_object.find_or_add_repository(full_filename, "en")
    assert_equal 1, processing_shared_library_object.find_or_add_repository(full_filename, "en")
    assert_equal 2, processing_shared_library_object.find_or_add_repository(full_filename, "ar")
    assert_equal 2, processing_shared_library_object.find_or_add_repository(full_filename, "ar")
    assert_equal 2, processing_shared_library_object.find_or_add_repository(full_filename, "ar")
    assert_raise (RuntimeError) {processing_shared_library_object.find_or_add_repository(full_filename, "!")}
    assert_equal expected_text, IO.read(full_filename)
  end

  #Test that handling of Australian parliament data works
  def test_aph_processing
    require 'process_aph'
    input_filename = @program_test_directory + "aph_reps_fragment.txt"
    actual_filename = @program_test_directory + "actual_aph_articles.sql"
    expected_filename = @program_test_directory + "expected_aph_articles.sql"
    File.delete(actual_filename) if File.exist?(actual_filename)
    ProcessAph.new.do_analysis(input_filename, actual_filename)
    assert File.exist?(actual_filename)
    assert_equal IO.read(expected_filename), IO.read(actual_filename)
  end
end

