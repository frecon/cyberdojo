class GitDiffParserTests < ActionController::TestCase 

  #-----------------------------------------------------
  
    was_line =  '--- a/sand box/xxx'
    assert_equal 'a/sand box/xxx', 
      GitDiffParser.new(was_line).parse_was_filename
  end
  #-----------------------------------------------------
  def test_parse_diff_for_deleted_file
    was_line =  '--- a/sandbox/xxx'
    assert_equal 'a/sandbox/xxx', 
      GitDiffParser.new(was_line).parse_was_filename
      now_line = '+++ /dev/null'
      assert_equal '/dev/null',
      GitDiffParser.new(now_line).parse_now_filename
  
  
  def test_parse_diff_for_new_file
    was_line =  '--- /dev/null'
    assert_equal '/dev/null', 
      GitDiffParser.new(was_line).parse_was_filename
    now_line = '+++ b/sandbox/untitled_6TJ'
    assert_equal 'b/sandbox/untitled_6TJ',
      GitDiffParser.new(now_line).parse_now_filename
  end
  
  #-----------------------------------------------------
  
  def test_parse_diff_deleted_file
    
diff --git a/sandbox/original b/sandbox/original
index e69de29..0000000
expected =
{
  'a/sandbox/original' =>
  {
    :prefix_lines => 
    [
        "diff --git a/sandbox/original b/sandbox/original",
        "deleted file mode 100644",
        "index e69de29..0000000",
    ],
    :was_filename => 'a/sandbox/original',
    :now_filename => '/dev/null',
    :chunks => []
  }
}

    parser = GitDiffParser.new(lines)    
    actual = parser.parse_all
    assert_equal expected, actual
  def test_parse_diff_for_renamed_but_unchanged_file
    
diff --git a/sandbox/oldname b/sandbox/newname
similarity index 100%
rename from sandbox/oldname
rename to sandbox/newname
expected =
{
  'b/sandbox/newname' =>
  {
    :prefix_lines => 
    [
        "diff --git a/sandbox/oldname b/sandbox/newname",
        "similarity index 100%",
        "rename from sandbox/oldname",
        "rename to sandbox/newname",
    ],
    :was_filename => 'a/sandbox/oldname',
    :now_filename => 'b/sandbox/newname',
    :chunks => []
  }
}

    parser = GitDiffParser.new(lines)    
    actual = parser.parse_all
    assert_equal expected, actual

  end
    
  #-----------------------------------------------------
  
  def test_parse_diff_for_renamed_and_changed_file
    
lines = <<HERE
diff --git a/sandbox/instructions b/sandbox/instructions_new
similarity index 87%
rename from sandbox/instructions
rename to sandbox/instructions_new
index e747436..83ec100 100644
--- a/sandbox/instructions
+++ b/sandbox/instructions_new
@@ -6,4 +6,4 @@ For example, the potential anagrams of "biro" are
 biro bior brio broi boir bori
 ibro ibor irbo irob iobr iorb
 rbio rboi ribo riob roib robi
-obir obri oibr oirb orbi orib
+obir obri oibr oirb orbi oribx
HERE

expected_diff = 
            "diff --git a/sandbox/instructions b/sandbox/instructions_new",
            "similarity index 87%",
            "rename from sandbox/instructions",
            "rename to sandbox/instructions_new",
            "index e747436..83ec100 100644"
          :was_filename => 'a/sandbox/instructions',
          :now_filename => 'b/sandbox/instructions_new',
                :was => { :start_line => 6, :size => 4 },
                :now => { :start_line => 6, :size => 4 },
              :before_lines => 
                [ 
                  "biro bior brio broi boir bori",
                  "ibro ibor irbo irob iobr iorb",
                  "rbio rboi ribo riob roib robi"
                ],
                  :deleted_lines => [ "obir obri oibr oirb orbi orib" ],
                  :added_lines   => [ "obir obri oibr oirb orbi oribx" ],
                  :after_lines => []
          ] # chunks  
    }

    expected = { 'b/sandbox/instructions_new' => expected_diff }
    parser = GitDiffParser.new(lines)    
    actual = parser.parse_all
    assert_equal expected, actual