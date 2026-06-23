import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme.dart';
import 'settings_button.dart';

PreferredSizeWidget forkastAppBar(BuildContext context, {List<Widget>? actions}) {
  final tokens = Theme.of(context).extension<ForkastTokens>()!;
  return AppBar(
    titleSpacing: 16,
    title: SvgPicture.asset(
      'assets/forkast-wordmark.svg',
      height: 28,
      colorFilter: ColorFilter.mode(tokens.ink, BlendMode.srcIn),
    ),
    actions: [
      if (actions != null) ...actions,
      const SettingsButton(),
      const SizedBox(width: 4),
    ],
  );
}
