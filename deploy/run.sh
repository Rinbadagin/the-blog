#!/bin/bash 
# Deploy changes and run webhook for discord notification
bundle install;
bin/rails assets:precompile;
bin/rails db:migrate;
bin/rails restart;

curl -X POST https://discord.com/api/webhooks/1269189137626435585/buHg27T3hZNlExY9sGcdf_sve6CA9mTAJjWyBMEFdODJUYlKnMkla_OHvCeXq6BPD3Tb \
    -d "content=Updated Klara's blog (klara.nz) to $(git log --oneline | head -n 1) via action"