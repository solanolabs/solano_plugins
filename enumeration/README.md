# Enumeration Scripts

These scripts run at the beginning of your Solano CI Session, determining which tests to run or not to run. This gives you the ability to programatically modify which tests are executed instead of statically defining a set of tests that are executed on each CI build.

The folders above contain example enumeration scripts - the scripts are organized by implementation language.

## Bash
  - [Basic Enumeration](./bash/basic_enumeration.sh) (search project directory for file patterns and add matching tests to the enumeration JSON)
  
## Ruby
  - [Basic Enumeration](./ruby/basic_enumeration.rb) (search project directory for file patterns and add matching tests to the enumeration JSON)
  - [Rerun Enumeration](./ruby/rerun_enumeration.rb) (queries the Solano CI API and identifies the tests that failed in the last Session - only running the failed tests)
  - [Filters Enumeration](./ruby/filters_enumeration.rb) (identifies the files that have been recently edited in the project, and runs the corresponding tests)
  
## PHP
  - [Basic Enumeration](./php/basic_enumeration.php) (search project directory for file patterns and add matching tests to the enumeration JSON, ready for parallelized PHP testing)
  - [Enumeration with PHPUnit](https://github.com/solanolabs/enumeration_with_phpunit) (uses a PHPUnit "dry run" to populate the enueration JSON, ready for parallelized PHP testing)

See [the custom enumeration documentation](http://docs.solanolabs.com/Beta/custom-enumeration/) for more info.
