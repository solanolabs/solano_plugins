import fnmatch, os, json, glob, re

jsonarray = {}
files = []

patterns = {
  "default"    : "^tests\/test_.*\.py$"
  }

#get profile name
profile = os.environ["SOLANO_PROFILE_NAME"]
print "selected profile: " + profile

#get the repo root
repo_root = os.path.abspath(os.environ["TDDIUM_REPO_ROOT"])
# test_dir = os.path.join(repo_root, 'test')
test_dir = repo_root

print "repo_root is set as: " + repo_root
print "test_dir is set as: " + test_dir

#figure out what pattern to use
if profile in patterns:
  profile_pattern = patterns[profile]
else:
  print "profile not found in patterns falling back to default"
  profile_pattern = patterns['default']
  profile = 'default'

regex=re.compile(profile_pattern)

print "selected pattern: " + profile_pattern

os.chdir(test_dir)
files = []
for root, dirnames, filenames in os.walk(test_dir):
  for filename in filenames:
    #paths need to be freom the TDDIUM_REPO_ROOT
    name = os.path.join(re.sub(repo_root+"\/", '', root), filename)
    if regex.search(name):
      files.append(name)

#printing so they appear in enumeration.log
print files

#set up parallel command mode
#should be a list of dictionaries
commands = [{
      "type"            : "nosetests",
      "mode"            : "parallel",
      "files"           :  [profile_pattern],
      "files_expanded"  : files
      }]

print commands

#adds a test that is always true
#if we dont find any tests we need this
if len(files) == 0:
  commands = ["/bin/true"]

# #build test_list.json
jsonarray['commands'] = commands

os.chdir(repo_root)
f = open('test_list.json', 'w')
f.write(json.dumps(jsonarray))
f.close()

