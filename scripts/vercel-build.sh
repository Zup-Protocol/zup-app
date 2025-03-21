#!/bin/bash
 
ENV=""

if [[ $VERCEL_ENV == "production"  ]] ; then 
   ENV="prod"
else 
   ENV="stage"
fi

flutter/bin/dart run build_runner build --delete-conflicting-outputs \
&& flutter/bin/dart run web3kit:generate_abis \
&& flutter/bin/dart run routefly \
&& flutter/bin/flutter build web --release --dart-define=env=$ENV

