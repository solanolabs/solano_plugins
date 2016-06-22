<?php
$json = array();
$commands = array();

$patterns = array(
  "default"     =>   "tests/\w*Test.php",
  "subscriber"  =>   "tests/Subscriber/.*Test.php",
  "event"       =>   "tests/event/.*Test.php"
  );

//get profile name
$profile = getenv("SOLANO_PROFILE_NAME");
echo "selected profile: $profile" . PHP_EOL;

//get the repo root
$root = realpath(getenv("TDDIUM_REPO_ROOT"));
$test_dir = realpath($root . DIRECTORY_SEPARATOR . 'tests');
echo "root is set as: $root" . PHP_EOL;
echo "test_dir is set as: $test_dir" . PHP_EOL;

//figure out what pattern to use
if (array_key_exists($profile, $patterns)) {
  $profile_pattern = $patterns[$profile];
} else {
  echo "profile not found in patterns falling back to default" . PHP_EOL;
  $profile_pattern = $patterns['default'];
}

echo "selected pattern: $profile_pattern" . PHP_EOL;

//grab files in repo root
$directory = new RecursiveDirectoryIterator($test_dir);
$flattened = new RecursiveIteratorIterator($directory);

//paths should be from repo_root
$clean_files=new RegexIterator($flattened,'#(' . preg_quote($root) . DIRECTORY_SEPARATOR .')(.*)#',  RegexIterator::REPLACE);
$clean_files->replacement='$2';

$files = new RegexIterator($clean_files, '#' . $profile_pattern . '$#Di');


//printing so they appear in enumeration.log
foreach($files  as $file) {
    echo $file . PHP_EOL;
}

//set up parallel command mode
$commands[] = array(
      "type"            => "phpunit",
      "mode"            => "parallel",
      "output"          => "exit-status",
      "command"         => "vendor/bin/solano-phpunit",
      "config"          => "phpunit.xml",
      "files"           => $profile_pattern,
      "files_expanded"  => array_values(iterator_to_array($files ))
      );

//adds a test that is always true
//if we dont find any tests we need this
$commands[] = "/bin/true";

//build test_list.json
$json['commands'] = $commands;

$fp = fopen('test_list.json', 'w');
fwrite($fp, json_encode($json));
fclose($fp);
