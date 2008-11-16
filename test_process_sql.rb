require 'test/unit'
require 'stringio'
require 'processing_shared_library'
require 'process_aph'
require 'process_top_level'

class TestSQLParsing < Test::Unit::TestCase
  def setup
    @program_test_directory = "program_test_data/"
    actual_filenames_without_directory = ["actual_howiki_redirect_with_new_statements.sql", "actual_howiki_redirect_with_nomainspace.sql", "test_adding_repository.sql", "actual_aph_articles.sql"]
    actual_filenames_without_directory.each do |filename_without_directory|
      filename = @program_test_directory + filename_without_directory
      File.delete(filename) if File.exists?(filename)
    end
    filenames_in_root_directory = ["howiki-20080616-page-fully-processed.sql", "howiki-20000101-redirect-almost-processed.sql", "howiki-20000101-redirect-fully-processed.sql", "howiki-20080616-page-almost-processed.sql"]
    filenames_in_root_directory.each {|filename| File.delete(filename) if File.exists?(filename)}
  end

  def test_howiki_pages
    repository_id = 3
    comparison_groups = [ 
["simplified_original_howiki-20080616-page.sql", "expected_howiki-20080616-page.sql"],
["simplified_original_howiki-20080616-page_mod_1.sql", "expected_howiki-20080616-page.sql"],
["simplified_original_howiki-20080616-page_mod_2.sql", "expected_howiki-20080616-page.sql"] ]
    comparison_groups.each do |original_file_name, expected_file_name|
      File.open("#{@program_test_directory + original_file_name}") do |original_file|
        intermediate_file = StringIO.new
        ProcessPageSql.new.main_method(repository_id, original_file, intermediate_file)
        intermediate_file.rewind

        actual_file = StringIO.new
        ProcessRemoveLastComma.new.main_method(intermediate_file, actual_file)
        actual_file.rewind

        File.open("#{@program_test_directory + expected_file_name}") do |expected_file|
          assert_equal expected_file.read, actual_file.read, "Inconsistency between actual and expected results derived from #{@program_test_directory + original_file_name}"
        end
      end
    end
  end

  def test_howiki_redirects
    repository_id = 3
    maximum_repository_statements = 0
    redirect_comparison_groups = [ ["original_howiki_redirect.sql", "expected_howiki_redirect.sql"], 
["original_howiki_redirect_mod_1.sql", "expected_howiki_redirect.sql"] ]
    redirect_comparison_groups.each do |original_file_name, expected_file_name|
      File.open("#{@program_test_directory + original_file_name}") do |original_file|
        intermediate_file = StringIO.new
        ProcessRedirectSql.new.main_method(repository_id, maximum_repository_statements, original_file, intermediate_file)
        intermediate_file.rewind

        actual_file = StringIO.new
        ProcessRemoveLastComma.new.main_method(intermediate_file, actual_file)
        actual_file.rewind

        File.open("#{@program_test_directory + expected_file_name}") do |expected_file|
          assert_equal expected_file.read, actual_file.read, "Inconsistency between actual and expected results derived from #{@program_test_directory + original_file_name}"
        end
      end
    end
  end

  #Redirects are getting longer, rather than shorter, and are bumping up against the size limit. I could increase the size limit, but I may not be able to do that everywhere
  def test_new_statement_addition
    program_test_directory = "program_test_data/"
    comparison_groups = [
["original_howiki_redirect.sql", "actual_howiki_redirect_with_new_statements.sql", "expected_howiki_redirect_with_new_statements.sql", [3, 1] ], 
["nomainspace_howiki_redirect.sql", "actual_howiki_redirect_with_nomainspace.sql", "expected_howiki_redirect_with_nomainspace.sql", [3, 1] ] 
]
    comparison_groups.each do |original_file_name, actual_file_name, expected_file_name, options|
      process_redirect_sql_object = ProcessRedirectSql.new
      process_remove_last_comma_object = ProcessRemoveLastComma.new
      repository_id, maximum_repository_statements = options
      File.open(program_test_directory + original_file_name) do |original_file|
        almost_processed_file = StringIO.new
        fully_processed_file = StringIO.new

        process_redirect_sql_object.main_method(repository_id, maximum_repository_statements, original_file, almost_processed_file)
        almost_processed_file.rewind
        process_remove_last_comma_object.main_method(almost_processed_file, fully_processed_file)
        fully_processed_file.rewind

        text1 = IO.read("#{program_test_directory + expected_file_name}")
        text2 = fully_processed_file.read
        assert_equal text1, text2
      end
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
    original_text = "insert into `repositories` (id, abbreviation, short_description, created_at, updated_at) VALUES (1,'enwiki','English language Wikipedia',now(),now());"
    expected_text = "insert into `repositories` (id, abbreviation, short_description, created_at, updated_at) VALUES (1,'enwiki','English language Wikipedia',now(),now()),(2,'arwiki','Arabic language Wikipedia',now(),now());" 
    full_filename = "program_test_data/test_adding_repository.sql"
    File.open(full_filename, "w") do |f|
      f.write(original_text)
    end
    processing_shared_library_object = ProcessingSharedLibrary.new
    assert_equal 2, processing_shared_library_object.add_repository(full_filename, "ar")
    assert_message_raised("Already exists") {processing_shared_library_object.add_repository(full_filename, "en")}
    assert_message_raised("Language code not found") {processing_shared_library_object.add_repository(full_filename, "!")}
    assert_message_raised("Already exists") {processing_shared_library_object.add_repository(full_filename, "ar")}
    assert_equal expected_text, IO.read(full_filename)
  end

  def test_repository_finding_or_adding
    original_text = ""
    expected_text = "insert into `repositories` (id, abbreviation, short_description, created_at, updated_at) VALUES (1,'enwiki','English language Wikipedia',now(),now()),(2,'arwiki','Arabic language Wikipedia',now(),now());" 
    full_filename = "program_test_data/test_adding_repository.sql"
    #File.open(full_filename, "w") do |f|
    #  f.write(original_text)
    #end
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

  #Test that process top level can handle article dumps
  def test_process_top_level_handling_articles
    original_article_dump_filename = @program_test_directory + "howiki-20080616-page.sql"
    expected_article_filename = @program_test_directory + "expected_howiki-20080616-page.sql"
    actual_article_filename = "howiki-20080616-page-fully-processed.sql"
    repository_creation_filename = @program_test_directory + "two_item_repository.sql"
    process_top_level_object = ProcessTopLevel.new
    process_top_level_object.main_method(repository_creation_filename, [original_article_dump_filename])
    assert File.read(expected_article_filename) == File.read(actual_article_filename)
  end

  #Test that process top level can handle redirect dumps
  def test_process_top_level_handling_redirects
    original_redirect_dump_filename = @program_test_directory + "howiki-20000101-redirect.sql"
    expected_redirect_filename = @program_test_directory + "expected_howiki_redirect.sql"
    actual_redirect_filename = "howiki-20000101-redirect-fully-processed.sql"
    repository_creation_filename = @program_test_directory + "two_item_repository.sql"
    process_top_level_object = ProcessTopLevel.new
    process_top_level_object.main_method(repository_creation_filename, [original_redirect_dump_filename])
    assert File.read(expected_redirect_filename) == File.read(actual_redirect_filename)
  end


  #Test that handling of Australian parliament data works
  def test_aph_processing
    input_filename = @program_test_directory + "aph_reps_fragment.txt"
    actual_filename = @program_test_directory + "actual_aph_articles.sql"
    expected_filename = @program_test_directory + "expected_aph_articles.sql"
    ProcessAph.new.do_analysis(input_filename, actual_filename)
    assert File.exist?(actual_filename)
    assert_equal IO.read(expected_filename), IO.read(actual_filename)
  end

  #Assert that a run time error is raised with a specific error message
  def assert_message_raised(message)
    begin
      yield
    rescue RuntimeError => error
      assert error.to_s == message, "Wrong runtime error message delivered"
    rescue
      assert false, "Different error type raised"
    else
      assert false, "No error raised"
    end
  end
end

