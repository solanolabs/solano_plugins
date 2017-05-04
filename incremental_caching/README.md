![Solano Labs Logo](https://www.solanolabs.com/assets/solano-labs-1cfeb8f4276fc9294349039f602d5923.png) 
# Incremental Cacheing

The [incremental cacheing docs page](http://docs.solanolabs.com/Beta/incremental-caching/) includes relatively
simple examples of implementing incremental caching on Solano CI. By storing the calculated hashes during a build,
subsequent builds can retrieve this information to determine which [setup hook](http://docs.solanolabs.com/Setup/setup-hooks/)
tasks need to be executed.

[key_calc_hash_and_store.sh](./key_calc_hash_and_store.sh) calculates the combined hash value of the supplied `<path>`
arguments and stores it by `<name>` for reference later in the session. Usage:
```
./key_calc_hash_and_store.sh <name> <path> [<path> ...]
```

[key_hash_current.sh](./key_hash_current.sh) checks if this hash value is the same as one potentially supplied by
a restored cache and exits zero if the hashes are both present and match. Usage:
```
./key_hash_current.sh <name>
```

The following `solano.yml` configuration examples reference these scripts to:

#### Perform `bundle install` only when necessary:

```yaml
hooks:
  pre_setup: |
    set -e # Exit on error
    if [ ! ./key_hash_current.sh bundle ]; then
      # Install required gems
      bundle install --path=$HOME/bundle --no-deployment
      # Remove unused gems to ensure a clean build environment
      bundle clean
    fi
cache:
  update_scripts:
    bundle:
      key_script: ./key_calc_hash_and_store.sh bundle Gemfile Gemfile.lock
      paths: 
        - HOME/bundle
        - HOME/.gem
  key_paths: [] # override Solano CI defaults
  save_paths:
    - HOME/cache-keys # Save the calculated hashes for use in subsequent Solano CI builds
```

#### Perform `npm install` only when necessary:

```yaml
hooks:
  pre_setup: |
    set -e # Exit on error
    if [ ! ./key_hash_current.sh node ]; then
      # Install required node modules
      npm install
      # Remove unused node modules to ensure a clean build environment
      npm rune
    fi
cache:
  update_scripts:
    bundle:
      key_script: ./key_calc_hash_and_store.sh node package.json # and/or 'npm-shrinkwrap.json'
      paths: 
        - node_modules
  key_paths: [] # override Solano CI defaults
  save_paths:
    - HOME/cache-keys # Save the calculated hashes for use in subsequent Solano CI builds
```

#### Save database dump file in the cache, and only recreate it when necessary:

```yaml
hooks:
  pre_setup: |
    set -e # Exit on error
    if [ ! ./key_hash_current.sh database ]; then
      # Prepare database
      RAILS_ENV=test bundle exec rake db:drop db:create db:schema:load
      # Dump database to file
      pg_dump $TDDIUM_DB_NAME > $HOME/db_dump.sql
    fi
  worker_setup: |
    set -e # Exit on error
    # Load per-worker database (conditional to ensure compatibility with Solano CI worker models)
    if [[ "No relations found." == "`psql $TDDIUM_DB_NAME -c \"\\dt\"`" ]]; then
      psql $TDDIUM_DB_NAME < $HOME/db_dump.sql
    fi
cache:
  update_scripts:
    database:
      key_script: ./key_calc_hash_and_store.sh database db # Presumes database configuration is in 'db' directory
      paths: 
        - HOME/db_dump.sql
  key_paths: [] # override Solano CI defaults
  save_paths:
    - HOME/cache-keys # Save the calculated hashes for use in subsequent Solano CI builds
```
