# baarcari
## Overview
**baarcari** is Unnecessary item transfer system.

**DO NOT USE AS REFERENCE** because of possible vulnerabilities.
Soon, Plans to be a bad application.

## Setup
Execute the following commands one at a time.

```
git clone https://github.com/yu1hpa/baarcari.git
cd baarcari && docker compose up -d
docker compose exec baarcari /bin/sh
bundle exec rake db:migrate
bundle exec rake db:seed
```

## Dependencies
Ruby v3.0.4  
Sinatra v3.0.3

others, see [Gemfile](./app/Gemfile)

## LICENSE
the Apache License, Version2.0.

## Author
yu1hpa
