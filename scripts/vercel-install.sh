FLUTTER_VERSION=$(jq -r '.flutter' .fvmrc) 

git clone https://github.com/flutter/flutter.git -b stable && \
ls && \
cd flutter && \
git checkout $FLUTTER_VERSION && \
cd .. && \
flutter/bin/flutter doctor && \
flutter/bin/flutter clean && \
flutter/bin/flutter pub get