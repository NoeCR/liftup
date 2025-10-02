import 'package:flutter/material.dart';
import 'localization_service.dart';

/// Widget helper para mostrar texto localizado
class LocalizedText extends StatelessWidget {
  final String textKey;
  final Map<String, dynamic>? params;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextScaler? textScaler;

  const LocalizedText(
    this.textKey, {
    super.key,
    this.params,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.textScaler,
  });

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.instance;
    
    String text;
    if (params != null) {
      text = localizationService.getStringWithParams(textKey, params!);
    } else {
      text = localizationService.getString(textKey);
    }

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      textScaler: textScaler,
    );
  }
}

/// Extensión para facilitar el acceso a las cadenas localizadas
extension LocalizationExtension on BuildContext {
  String localizedString(String key, [Map<String, dynamic>? params]) {
    final localizationService = LocalizationService.instance;
    if (params != null) {
      return localizationService.getStringWithParams(key, params);
    }
    return localizationService.getString(key);
  }
}

/// Widget para mostrar un AppBar con título localizado
class LocalizedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleKey;
  final Map<String, dynamic>? titleParams;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double? scrolledUnderElevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final ShapeBorder? shape;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  final bool primary;
  final bool centerTitle;
  final double? titleSpacing;
  final double? toolbarHeight;
  final double? leadingWidth;
  final bool forceMaterialTransparency;

  const LocalizedAppBar({
    super.key,
    required this.titleKey,
    this.titleParams,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.scrolledUnderElevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.shape,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.centerTitle = false,
    this.titleSpacing,
    this.toolbarHeight,
    this.leadingWidth,
    this.forceMaterialTransparency = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: LocalizedText(titleKey, params: titleParams),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      shape: shape,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      primary: primary,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      forceMaterialTransparency: forceMaterialTransparency,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
