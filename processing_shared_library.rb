class ProcessingSharedLibrary
  #Definitions for int, varchar, double, comma
  def self.int
    int = '-?\\d*'
  end

  def self.varchar
    varchar = '\'(?:[^\\\']|\\\\\\\')*\''
  end

  def self.double
    double = '-?(?:\\d+\\.\\d+|\\d\\.\\d+e\\-\\d+)'
  end

  def self.comma
    comma = ','
  end

  #For sql code like now()
  def self.function
    function = '\w+\(\)'
  end

  #Return an array containing all of the repositories listed
  def list_repositories(file)
    repository_text = file.read
#    puts repository_text, "***"
    int, varchar, double, comma, function = ProcessingSharedLibrary.int, ProcessingSharedLibrary.varchar, ProcessingSharedLibrary.double, ProcessingSharedLibrary.comma, ProcessingSharedLibrary.function
    fields = [int, varchar, varchar, function, function]
    record_re = /#{'\\((' + fields.join( '),(' ) + ')\\)'}/
#    puts record_re, "!!!"
    results = []
#    raise "No match found between #{repository_text} and #{record_re}" unless repository_text =~ record_re
    repository_text.scan(record_re) do |id_match, abbreviation_match, short_description_match, created_at_match, updated_at_match|
      id = Integer(id_match)
      abbreviation = abbreviation_match[1..-2]
      short_description = short_description_match[1..-2]
      created_at = created_at_match
      updated_at = updated_at_match
      #puts id_match, abbreviation_match, short_description_match, created_at_match, updated_at_match
      results << [id, abbreviation, short_description, created_at, updated_at]
    end
    results
  end

  def find_repository(filename, language_code)
    unless File.exists?(filename)
      return nil
    end
    repository_text = IO.read(filename)
#    puts repository_text, repository_text.class
    int, varchar, double, comma, function = ProcessingSharedLibrary.int, ProcessingSharedLibrary.varchar, ProcessingSharedLibrary.double, ProcessingSharedLibrary.comma, ProcessingSharedLibrary.function
    fields = [int, varchar, varchar, function, function]
    record_re = /#{'\\((' + fields.join( '),(' ) + ')\\)'}/
    desired_abbreviation = "'" + language_code + "wiki'"
#    raise "No match found between #{repository_text} and #{record_re}" unless repository_text =~ record_re
    repository_text.scan(record_re) do |id_match, abbreviation_match, short_description_match, created_at_match, updated_at_match|
#      puts id_match, abbreviation_match, short_description_match, created_at_match, updated_at_match
      if desired_abbreviation == abbreviation_match
#        puts "id match is #{id_match}"
        return Integer(id_match)
      end
    end
    return nil 
  end

  #Return an id that is currently unused in the repository
  #The contract currently doesn't stipulate what the id has to be
  def find_unused_repository_id(file)
    repositories = list_repositories(file)
    repository = repositories.max{|a,b| a[0] <=> b[0]}
    if repositories.empty?
      return 1
    else
      return repository[0] + 1
    end
  end

  def add_repository(filename, language_code)
    #Check that it isn't already in there
    raise "Already exists" unless find_repository(filename, language_code).nil? #Not heckle proof
    language_code_object = LanguageCode.new
    raise "Language code not found" if language_code_object.language_code[language_code].nil?
    abbreviation = language_code + "wiki"
    short_description = language_code_object.language_code[language_code] + " language Wikipedia"
    created_at = "now()"
    updated_at = "now()"
    if File.exists?(filename)
      repository_id = find_unused_repository_id(File.open(filename))
      file_text = File.open(filename).read
    else
      repository_id = 1 
      file_text = "" 
    end
    if file_text.strip.empty?
      file_text = "insert into `repositories` (id, abbreviation, short_description, created_at, updated_at) VALUES ;"
    end
    file_text.gsub!(/( |\));\Z/) do
      if $1 == " "
        $1 + "(#{repository_id},'#{abbreviation}','#{short_description}',#{created_at},#{updated_at});"
      else
        $1 + ",(#{repository_id},'#{abbreviation}','#{short_description}',#{created_at},#{updated_at});"
      end
    end
    file = File.new(filename, "w")
    file << file_text
    file.close
    return repository_id
  end
  #def self.add_repository_with_parameters(file, abbreviation, id=nil, short_description=nil, created_at=nil, updated_at=nil)

  #Either find the repository_id (if the language_code exists) or create a repository_id and return it (if it doesn't)
  def find_or_add_repository(filename, language_code)
    repository_id = find_repository(filename, language_code)
    if repository_id.nil?
      repository_id = add_repository(filename, language_code)
    end
    return repository_id
  end

end

class LanguageCode
  def language_code
{"bug"=>"Buginese", "roa-tara"=>"Tarantino", "bs"=>"Bosnian", "eo"=>"Esperanto", "ki"=>"Kikuyu", "ne"=>"Nepali", "ru"=>"Russian", "ur"=>"Urdu", "kj"=>"Kuanyama", "ng"=>"Ndonga", "aa"=>"Afar", "rw"=>"Kinyarwanda", "ho"=>"Hiri Motu", "ab"=>"Abkhazian", "tpi"=>"Tok Pisin", "es"=>"Spanish", "kk"=>"Kazakh", "kl"=>"Greenlandic", "et"=>"Estonian", "ta"=>"Tamil", "da"=>"Danish", "eu"=>"Basque", "km"=>"Khmer", "hr"=>"Croatian", "kn"=>"Kannada", "af"=>"Afrikaans", "ko"=>"Korean", "nl"=>"Dutch", "mus"=>"Muscogee", "ht"=>"Haitian", "te"=>"Telugu", "wa"=>"Walloon", "vec"=>"Venetian", "srn"=>"Sranan", "ga"=>"Irish", "hu"=>"Hungarian", "uz"=>"Uzbek", "kr"=>"Kanuri", "de"=>"German", "nn"=>"Norwegian (Nynorsk)", "tg"=>"Tajik", "vls"=>"West Flemish", "gan"=>"Gan", "ks"=>"Kashmiri", "no"=>"Norwegian (Bokmål)", "th"=>"Thai", "roa-rup"=>"Aromanian", "za"=>"Zhuang", "ak"=>"Akan", "gd"=>"Scottish Gaelic", "ti"=>"Tigrinya", "ja"=>"Japanese", "hy"=>"Armenian", "ku"=>"Kurdish", "bat-smg"=>"Samogitian", "hz"=>"Herero", "bxr"=>"Buryat (Russia)", "kv"=>"Komi", "lmo"=>"Lombard", "tk"=>"Turkmen", "am"=>"Amharic", "kw"=>"Cornish", "tl"=>"Tagalog", "udm"=>"Udmurt", "an"=>"Aragonese", "xal"=>"Kalmyk", "tn"=>"Tswana", "mdf"=>"Moksha", "ky"=>"Kirghiz", "dsb"=>"Lower Sorbian", "nv"=>"Navajo", "to"=>"Tongan", "zh"=>"Chinese", "pag"=>"Pangasinan", "pdc"=>"Pennsylvania German", "ar"=>"Arabic", "ceb"=>"Cebuano", "crh"=>"Crimean Tatar", "zh-yue"=>"Cantonese", "as"=>"Assamese", "ny"=>"Chichewa", "pa"=>"Punjabi", "qu"=>"Quechua", "tr"=>"Turkish", "cbk-zam"=>"Zamboanga Chavacano", "gl"=>"Galician", "ts"=>"Tsonga", "simple"=>"Simple English", "ext"=>"Extremaduran", "wo"=>"Wolof", "nrm"=>"Norman", "av"=>"Avar", "gn"=>"Guarani", "mg"=>"Malagasy", "mh"=>"Marshallese", "tt"=>"Tatar", "pam"=>"Kapampangan", "sah"=>"Sakha", "mi"=>"Maori", "sa"=>"Sanskrit", "ca"=>"Catalan", "ay"=>"Aymara", "lij"=>"Ligurian", "tw"=>"Twi", "nov"=>"Novial", "be-x-old"=>"Belarusian (Tarashkevitsa)", "kaa"=>"Karakalpak", "az"=>"Azeri", "dv"=>"Divehi", "mk"=>"Macedonian", "sc"=>"Sardinian", "pap"=>"Papiamentu", "kab"=>"Kabyle", "ml"=>"Malayalam", "sd"=>"Sindhi", "bar"=>"Bavarian", "pi"=>"Pali", "se"=>"Northern Sami", "ty"=>"Tahitian", "ilo"=>"Ilokano", "fa"=>"Persian", "map-bms"=>"Banyumasan", "gu"=>"Gujarati", "sg"=>"Sango", "dz"=>"Dzongkha", "ce"=>"Chechen", "gv"=>"Manx", "mn"=>"Mongolian", "ast"=>"Asturian", "tokipona"=>"Tokipona", "mzn"=>"Mazandarani", "mo"=>"Moldovan", "hak"=>"Hakka", "pl"=>"Polish", "sh"=>"Serbo-Croatian", "zu"=>"Zulu", "ve"=>"Venda", "si"=>"Sinhalese", "lbe"=>"Lak", "ch"=>"Chamorro", "ia"=>"Interlingua", "frp"=>"Franco-Provençal/Arpitan", "rmy"=>"Romani", "arc"=>"Assyrian Neo-Aramaic", "jv"=>"Javanese", "mr"=>"Marathi", "sk"=>"Slovak", "zea"=>"Zealandic", "ff"=>"Fula", "tum"=>"Tumbuka", "fiu-vro"=>"Võro", "ms"=>"Malay", "sl"=>"Slovenian", "cho"=>"Choctaw", "id"=>"Indonesian", "mt"=>"Maltese", "sm"=>"Samoan", "vi"=>"Vietnamese", "stq"=>"Saterland Frisian", "sn"=>"Shona", "ie"=>"Interlingue", "la"=>"Latin", "new"=>"Newar / Nepal Bhasa", "fi"=>"Finnish", "lb"=>"Luxembourgish", "nah"=>"Nahuatl", "so"=>"Somali", "fj"=>"Fijian", "ig"=>"Igbo", "ps"=>"Pashto", "fur"=>"Friulian", "chr"=>"Cherokee", "szl"=>"Silesian", "co"=>"Corsican", "pt"=>"Portuguese", "sq"=>"Albanian", "yi"=>"Yiddish", "my"=>"Burmese", "sr"=>"Serbian", "diq"=>"Zazaki", "ii"=>"Sichuan Yi", "als"=>"Alemannic", "vo"=>"Volapük", "lg"=>"Luganda", "eml"=>"Emilian-Romagnol", "cr"=>"Cree", "oc"=>"Occitan", "haw"=>"Hawaiian", "ss"=>"Swati", "st"=>"Sesotho", "ik"=>"Inupiak", "cs"=>"Czech", "fo"=>"Faroese", "glk"=>"Gilaki", "tet"=>"Tetum", "li"=>"Limburgian", "su"=>"Sundanese", "hsb"=>"Upper Sorbian", "zh-classical"=>"Classical Chinese", "chy"=>"Cheyenne", "cu"=>"Old Church Slavonic", "nap"=>"Neapolitan", "sv"=>"Swedish", "yo"=>"Yoruba", "pms"=>"Piedmontese", "ba"=>"Bashkir", "cv"=>"Chuvash", "fr"=>"French", "bcl"=>"Central_Bicolano", "sw"=>"Swahili", "io"=>"Ido", "wuu"=>"Wu", "cy"=>"Welsh", "ln"=>"Lingala", "be"=>"Belarusian", "lo"=>"Lao", "pih"=>"Norfolk", "is"=>"Icelandic", "om"=>"Oromo", "nds"=>"Low Saxon", "cdo"=>"Min Dong", "lad"=>"Ladino", "bg"=>"Bulgarian", "it"=>"Italian", "ha"=>"Hausa", "ang"=>"Anglo-Saxon", "bh"=>"Bihari", "fy"=>"West Frisian", "iu"=>"Inuktitut", "bi"=>"Bislama", "ug"=>"Uyghur", "bpy"=>"Bishnupriya Manipuri", "ee"=>"Ewe", "scn"=>"Sicilian", "sco"=>"Scots", "rm"=>"Romansh", "got"=>"Gothic", "ksh"=>"Ripuarian", "lt"=>"Lithuanian", "rn"=>"Kirundi", "nds-nl"=>"Dutch Low Saxon", "he"=>"Hebrew", "ka"=>"Georgian", "uk"=>"Ukrainian", "hif"=>"Fiji Hindi", "csb"=>"Kashubian", "bm"=>"Bambara", "lv"=>"Latvian", "or"=>"Oriya", "zh-min-nan"=>"Min Nan", "ro"=>"Romanian", "xh"=>"Xhosa", "myv"=>"Erzya", "bn"=>"Bengali", "os"=>"Ossetian", "bo"=>"Tibetan", "jbo"=>"Lojban", "el"=>"Greek", "na"=>"Nauruan", "hi"=>"Hindi", "war"=>"Waray-Waray", "br"=>"Breton", "en"=>"English", "kg"=>"Kongo"}
  end

end
