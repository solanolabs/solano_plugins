require 'yaml'
require 'json'
require 'open3'

module Enumerate
  def self.list_files
    cmd = "find . -type f -not -path '*/\.*'"
    rv = Open3.popen3(cmd) do |stdin, stdout, stderr, wait|
      stdin.close

      files = []
      while line = stdout.gets
        line.chomp!
        line.gsub!(/^\.\//, "")
        fields = splitquote(line)
        files.push(fields[0])
      end
      [wait, files]
    end
    if rv[0].value.exitstatus != 0 then
      raise "find . -type f -not -path '*/\.*' fails"
    end
    return rv[1]
  end

  def self.match(list, pat)
    return list.select { |fname| File.fnmatch?(pat, fname) }
  end

  def self.match_to_files(patterns, filenames)
    compiled_patterns = compile_pattern_sequence(patterns, nil)
    file_list = filenames.select do |f|
      match_pattern_sequence(compiled_patterns, f)
    end
    return file_list
  end

  # Compile a sequence of include/exclude patterns in our format to an
  # internal form accepted by match_pattern_sequence.
  def self.compile_pattern_sequence(patterns, prefix=nil)
    patterns.reverse.map do |pat|
      if pat.is_a?(String)
        pat = File.join(prefix, pat) if prefix
        [true,
         self.compile_glob(pat)]
      else
        patstring = pat.values[0]
        patstring = File.join(prefix, patstring) if prefix
        [pat.keys[0] == 'include',
         self.compile_glob(patstring)]
      end
    end
  end

  # Compile a glob in our format -- POSIX plus **, minus character
  # classes due to laziness -- to a Ruby regexp.
  def self.compile_glob(glob)
    # The rule that wildcards don't expand to include a dot at the
    # start of a path component contributes most of the complexity
    # in the implementation, particularly in interaction with the
    # ** wildcard, which can begin new path components.
    re = '\A'
    i = 0
    nodot = true
    while i < glob.size
      nextnodot = false
      case glob[i]
        when '?'
          re << (nodot ? '[^/.]' : '[^/]')
        when '*'
          if i+1 < glob.size and glob[i+1] == '*'
            # **
            # Any sequence **, ***, ****, etc. is equivalent.
            while i+2 < glob.size and glob[i+2] == '*'
              i += 1
            end
            starstarre = '(?:[^/]*/+[^/.])*[^/]*/*' # Any string without '/.'
            # Proof sketch for complex REs below: consider leftmost [^/.], if any
            if i+2 < glob.size and glob[i+2] == '?'
              # **? (or ***? etc) -- nonempty, no '/.'
              i += 2
              re << (nodot ? "(?:/*[^/.]#{starstarre}|/+)"
              : "(?:[.]*/*[^/.]#{starstarre}|[.]*/+|[.]+)")
            else
              # ** (or *** etc), not followed by ? -- any string without '/.'
              i += 1
              re << (nodot ? "(?:/*[^/.]#{starstarre}|/*)"
              : starstarre)
            end
          elsif i+1 < glob.size and glob[i+1] == '?'
            # *?
            i += 1
            re << (nodot ? '[^/.][^/]*' : '[^/]+')
          else
            # plain *, not followed by ?
            re << (nodot ? '(?:[^/.][^/]*|)' : '[^/]*')
          end
        when '\\'
          case i+1 < glob.size and glob[i+1]
            when *%w(? * \\ [)
              re << "\\#{glob[i+1]}"
              i += 1
            else # including false, for end of pattern
              raise "Bad escape sequence in glob: #{glob}"
          end
        when '['
          raise "Character classes not supported, in glob: #{glob}"
        when '/'
          nextnodot = true
          re << '/'
        when /[a-zA-Z0-9]/
          re << glob[i]
        else
          re << "\\#{glob[i]}"
      end
      i += 1
      nodot = nextnodot
    end
    re << '\z'
    Regexp.new(re)
  end

  # Determine if a string is included or excluded by the given patterns,
  # which must have been compiled by compile_pattern_sequence.
  def self.match_pattern_sequence(compiled_patterns, s)
    compiled_patterns.each do |incl, re|
      return incl if re.match(s)
    end
    return false
  end

  def self.splitquote(s)
    fields = []
    str = ''
    esc = false     # last character was an escape
    quote = false   # inside quotes
    s.chars do |c|
      if esc then
        case c
          when "t"
            str += "\t"
          when "n"
            str += "\n"
          else
            str += c
        end
        esc = false
        next
      elsif c == '\\' then
        esc = true
        next
      end
      if c == '"' then
        quote = !quote
      elsif !quote && c =~ /\s/ then
        if !str.empty? then
          fields.push(str)
          str = ''
        end
      else
        str += c
      end
    end
    if !str.empty? then
      fields.push(str)
    end
    return fields
  end
end

class ApiServer

  def initialize
    @debug = true
    @host = ENV['TDDIUM_API_SERVER'] || 'ci.solanolabs.com'
    @user_api_key = ENV['API_KEY'] # This needs to be supplied
  end

  def curl_json_user_key(method, data, url)
    opts ="-k -#"
    cmd = "curl #{opts} -X #{method} -H 'Content-type: application/json' -H 'X-Tddium-Api-Key: #{@user_api_key }' -d '#{data.to_json}' https://#{@host}/#{url}"
    puts cmd if @debug
    res = `#{cmd}`
    puts res if @debug
    JSON.parse(res)
  end
end

PATTERNS = {
  "default"     => %W(test/**.rb features/**.rb),
  "default2"    => %W(test/**.rb),
  "rerun"       => %W(test/**.rb features/**.rb),
}

def generate_test_files_json
  api = ApiServer.new()
  profile_name = ENV['SOLANO_PROFILE_NAME']
  puts "Using profile #{profile_name}"
  test_patterns = PATTERNS[profile_name]

  files = Enumerate.list_files
  file_list = Enumerate.match_to_files(test_patterns, files)
  file_list = file_list.uniq

  if profile_name == 'rerun' then
    suite_id = api.curl_json_user_key("GET", {}, "1/sessions/#{ENV['TDDIUM_SESSION_ID']}")['session']['suite_id']
    last_session = api.curl_json_user_key("GET", {"suite_id" => suite_id, "active" => false, "limit" => 1}, "1/sessions")['sessions'].first
    test_run_info = api.curl_json_user_key("GET", {}, "1/sessions/#{last_session['id']}/test_executions/query")['session']

    #if there where tests failures rerun those tests
    if test_run_info['session_status'] == 'failed' then
      tests = test_run_info['tests']
      tests.delete_if{ |x| x['status']=='passed'}
      failed_tests = tests.map{ |x| x['test_name']}
      file_list.delete_if{ |x| !failed_tests.include?(x)}
    end
  end

  to_run = {'tests' => file_list}

  File.open("test_list.json", "w") do |f|
    f.write(JSON.pretty_generate(to_run))
  end

  puts 'Generated test_list.json'
end

generate_test_files_json
