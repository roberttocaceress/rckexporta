import 'dart:math';

import 'package:flutter/cupertino.dart';

class DeviceDetector {
   int typeDevice1(MediaQueryData query) {  // 1 Smartphone //2 Tablet  //3  PC   // 4 TV
    var size = query.size;
    var diagonal = sqrt(
        (size.width * size.width) +
            (size.height * size.height)
    );
    if ( diagonal < 1100.0) {
      return 1;
    }
    if (  diagonal > 1100.0 && diagonal < 2100.0) {
      return 2;
    }
    if (  diagonal > 2100.0) {
      return 3;
    }
    return 4;
  }
   double isTablet2(MediaQueryData query) {
    var size = query.size;
    var diagonal = sqrt(
        (size.width * size.width) +
            (size.height * size.height)
    );

    return diagonal;
  }
   double typeDevice2(MediaQueryData query) {  // 1 Smartphone //2 Tablet  //3  PC   // 4 TV
     var size = query.size;
     var diagonal = sqrt(
         (size.width * size.width) +
             (size.height * size.height)
     );
     if ( diagonal < 1100.0) {
       return diagonal;
     }
     if (  diagonal >= 1100.0 && diagonal <= 2100.0) {
       return diagonal;
     }
     if (  diagonal > 2100.0) {
       return diagonal;
     }
     return diagonal;
   }

}