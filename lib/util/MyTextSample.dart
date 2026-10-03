import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTextSample{

  static TextStyle? display4(BuildContext context){
    return Theme.of(context).textTheme.displayLarge;
  }

  static TextStyle? display3(BuildContext context){
    return Theme.of(context).textTheme.displayMedium;
  }

  static TextStyle? display2(BuildContext context){
    return Theme.of(context).textTheme.displaySmall;
  }

  static TextStyle? display1(BuildContext context){
    return Theme.of(context).textTheme.headlineMedium;
  }

  static TextStyle? headline(BuildContext context){
    return Theme.of(context).textTheme.headlineSmall;
  }

  static TextStyle? title(BuildContext context){
    return Theme.of(context).textTheme.titleLarge;
  }

  static TextStyle medium0(BuildContext context){
    return (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontSize: 14,
    );
  }
  static TextStyle medium(BuildContext context){
    return (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontSize: 16,
    );
  }

  static TextStyle medium2(BuildContext context){
    return (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontSize: 18,
    );
  }

  static TextStyle medium3(BuildContext context){
    return (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontSize: 20,
    );
  }
  static TextStyle small(BuildContext context){
    return (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontSize: 12,
    );
  }

  static TextStyle small2(BuildContext context){
    return (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontSize: 14,
    );
  }

  static TextStyle large(BuildContext context){
    return (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
      fontSize: 34,
    );
  }
  static TextStyle large1(BuildContext context){
    return (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
      fontSize: 44,
    );
  }
  static TextStyle large2(BuildContext context){
    return (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
      fontSize: 54,
    );
  }

  //Large
  static TextStyle? subhead(BuildContext context){
    return Theme.of(context).textTheme.titleMedium;
  }

  static TextStyle? body2(BuildContext context){
    return Theme.of(context).textTheme.bodyLarge;
  }

  static TextStyle? body1(BuildContext context){
    return Theme.of(context).textTheme.bodyMedium;
  }

  static TextStyle? caption(BuildContext context){
    return Theme.of(context).textTheme.bodySmall;
  }

  static TextStyle? button(BuildContext context){
    return Theme.of(context).textTheme.labelLarge!.copyWith(
        letterSpacing: 1
    );
  }

  static TextStyle? subtitle(BuildContext context){
    return Theme.of(context).textTheme.titleSmall;
  }

  static TextStyle? overline(BuildContext context){
    return Theme.of(context).textTheme.labelSmall;
  }
}