import 'package:flutter/material.dart';

import '../values_and_localization/strings.dart';

class Localized {
  static String userLangCode;

  static Localized of(BuildContext context) {
    return Localizations.of<Localized>(context, Localized);
  }

  static String text({
    @required BuildContext context,
    @required String key,
  }) {
    return const StringsClass().localizedValues[userLangCode][key];
  }
}
