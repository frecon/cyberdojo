
module CodeOutputParser

  #  :red   - this means the tests ran but at least one failed
  #  :amber - this means the tests could not be run (eg syntax error)
  #  :green - this means the tests ran and all passed
  
  def self.parse(unit_test_framework, output)
    inc = { }
    if Regexp.new("Terminated by the cyber-dojo server after").match(output)
      inc[:colour] = :amber
    else
      inc[:colour] = eval "parse_#{unit_test_framework}(output)"
    end
    inc
  end

  def self.parse_node(output)
    red_pattern = /AssertionError/
    green_pattern = /^All tests passed/
    if output =~ green_pattern
      :green
    elsif output =~ red_pattern
      :red
    else
      :amber
    end
  end

  def self.parse_php_unit(output)
	amber_pattern = Regexp.new('PHP Parse error:')
    red_pattern = Regexp.new('FAILURES!')
    green_pattern = Regexp.new('OK \(')
    if amber_pattern.match(output)
	  :amber
    elsif red_pattern.match(output)
      :red
    elsif green_pattern.match(output)
      :green
    else
      :amber
    end
  end

  def self.parse_perl_test_simple(output)
    green_pattern = Regexp.new('All tests successful')
    syntax_error_pattern = Regexp.new('syntax error')
    compilation_aborted_pattern = Regexp.new('aborted due to compilation errors')
    if green_pattern.match(output)
      :green
    elsif syntax_error_pattern.match(output)
      :amber
    elsif compilation_aborted_pattern.match(output)
	  :amber
    else
      :red
    end
  end

  def self.parse_js_test_simple(output)
    amber_pattern = Regexp.new('Exception in thread "main" org.mozilla')
    red_pattern = Regexp.new('FAILED:assertEqual')
    if amber_pattern.match(output)
      :amber
    elsif red_pattern.match(output)
      :red
    else
      :green
    end
  end

  def self.parse_eunit(output) 
    red_pattern = Regexp.new('Failed: ')
    green_pattern = Regexp.new('passed.')
    if red_pattern.match(output)
      :red
    elsif green_pattern.match(output)
      :green
    else
      :amber
    end
  end
	
  def self.parse_python_unittest(output) 
    red_pattern = Regexp.new('FAILED \(failures=')
    green_pattern = Regexp.new('OK')
    if red_pattern.match(output)
      :red
    elsif green_pattern.match(output)
      :green
    else
      :amber
    end
  end
	
  def self.parse_catch(output)
    red_pattern = Regexp.new('\[Testing completed.*failed\]')
    green_pattern = Regexp.new('\[Testing completed.*succeeded\]')
    
    if red_pattern.match(output)
      :red
    elsif green_pattern.match(output)
      :green
    else
      :amber
    end
  end
  
  def self.parse_cassert(output)
    red_pattern = Regexp.new('(.*)Assertion(.*)failed.')
    syntax_error_pattern = Regexp.new(':(\d*): error')
    make_error_pattern = Regexp.new('^make:')
    makefile_error_pattern = Regexp.new('^makefile:')
    if red_pattern.match(output)
      :red
    elsif make_error_pattern.match(output)
      :amber
    elsif makefile_error_pattern.match(output)
	  :amber
    elsif syntax_error_pattern.match(output)
      :amber
    else
      :green
    end
  end

  def self.parse_ruby_test_unit(output)
    ruby_pattern = Regexp.new('^(\d*) tests, (\d*) assertions, (\d*) failures, (\d*) errors')
    if match = ruby_pattern.match(output)
      if match[4] != "0"
        :amber
      elsif match[3] != "0"
        :red
      else
        :green
      end
    else
      :amber
    end
  end

  def self.parse_ruby_rspec(output)
	if /\A\.+$/ =~ output
      :green
    elsif /\A[\.F]+$/ =~ output
      :red
    else
      :amber
    end	
  end

  def self.parse_nunit(output)
    nunit_pattern = /^Tests run: (\d*)(, Errors: (\d+))?, Failures: (\d*)/
    if output =~ nunit_pattern
      if $4 == "0" and ($3.blank? or $3 == "0")
        :green
      else
        :red
      end
    else
      :amber
    end
  end
  
  def self.parse_junit(output)
    junit_green_pattern = Regexp.new('^OK \((\d*) test')
    if match = junit_green_pattern.match(output)
      if match[1] != "0" 
        :green
      else # treat zero passes as a fail
        :red 
      end
    else
      junit_red_pattern = Regexp.new('^Tests run: (\d*),  Failures: (\d*)')
      if match = junit_red_pattern.match(output)
        :red
      else
        :amber
      end
    end
  end

  def self.parse_jasmine(output)
     jasmine_pattern = /(\d+) tests?, (\d+) assertions?, (\d+) failures?/
     if jasmine_pattern.match(output)
        return $3 == "0" ? :green : :red
     else
        :amber
     end
  end

  def self.parse_hunit(output)
    if output =~ /Counts \{cases = (\d+), tried = (\d+), errors = (\d+), failures = (\d+)\}/
      if $3.to_i != 0
        :amber
      elsif $4.to_i != 0
        :red
      else
        :green
      end
    else
      :amber
    end
  end

  def self.parse_cpputest(output)
    failed_pattern = /Errors /
    passed_pattern = /OK /
    if failed_pattern.match(output)
      :red
    elsif passed_pattern.match(output)
      :green
    else
      :amber  
    end
  end

  def self.parse_googletest(output)
     failed_pattern = Regexp.new('(.*)FAILED(.*)')
     syntax_error_pattern = Regexp.new(':(\d*): error')
     make_error_pattern = Regexp.new('^make:')
     if failed_pattern.match(output)
       :red
     elsif make_error_pattern.match(output)
       :amber
     elsif syntax_error_pattern.match(output)
       :amber
     else
       :green
     end
  end
 
  def self.parse_go_testing(output)
    didnt_build_pattern = /\[build failed\]/
    failed_pattern = /FAIL/
    passed_pattern = /PASS/
    if didnt_build_pattern.match(output)
      :amber
    elsif failed_pattern.match(output)
      :red
    elsif passed_pattern.match(output)
      :green
    else
      :amber  
    end
  end
  
  def self.parse_scala_test(output)
	:amber
  end
  
  def self.parse_clojure_test(output)
	syntax_error_pattern = /Exception in thread/	
    ran_pattern = /Ran (\d+) tests containing (\d+) assertions.(\s*)(\d+) failures, (\d+) errors./
    if syntax_error_pattern.match(output)
	  :amber
    elsif output.scan(ran_pattern).any? { |res| res[3] != "0" || res[4] != "0" }
	  :red
    elsif output.scan(ran_pattern).all? { |res| res[3] == "0" && res[4] == "0" }
	  :green
	else
	  :amber
	end    
  end

end

