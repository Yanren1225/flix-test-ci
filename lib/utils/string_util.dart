extension StringExtensions on String {
  String removeSubstring(String toRemove) {
    return replaceAll(toRemove, '');
  }

  // 一个忽略大小写移除子字符串的方法
  String removeSubstringIgnoreCase(String toRemove) {
    String lowerOriginal = toLowerCase();
    String lowerToRemove = toRemove.toLowerCase();

    String result = this;

    while (lowerOriginal.contains(lowerToRemove)) {
      int startIndex = lowerOriginal.indexOf(lowerToRemove);
      result =
          result.replaceRange(startIndex, startIndex + toRemove.length, '');
      lowerOriginal = result.toLowerCase();
    }

    return result;
  }

  bool isImgName() {
    var index = lastIndexOf(".");
    if (index == -1) {
      return false;
    }
    var lowName = substring(index+1, length).toLowerCase();
    var imgExtensions = [
      "bmp",
      "jpg",
      "png",
      "tif",
      "gif",
      "pcx",
      "tga",
      "exif",
      "fpx",
      "svg",
      "psd",
      "cdr",
      "pcd",
      "dxf",
      "ufo",
      "eps",
      "ai",
      "raw",
      "WMF",
      "webp",
      "avif",
      "apng"
    ];
    return imgExtensions.contains(lowName);
  }


  bool isVideoName() {
    var index = lastIndexOf(".");
    if (index == -1) {
      return false;
    }
    var lowName = substring(index+1, length).toLowerCase();
    List<String> videoExtensions = [
      "mp4",
      "avi",
      "mkv",
      "mov",
      "wmv",
      "flv",
      "f4v",
      "webm",
      "vob",
      "divx",
      "xvid",
      "rm",
      "rmvb",
      "mpg",
      "mpeg",
      "mpe",
      "m1v",
      "m2v",
      "mpv2",
      "m2p",
      "ts",
      "m2ts",
      "mts",
      "tp",
      "trp",
      "ty",
      "ifo",
      "bvr",
      "dv",
      "dif",
      "dv-avi",
      "gvi",
      "m4v",
      "ogm",
      "ogv",
      "qt",
      "movhd",
      "smv",
      "uvh",
      "uvhu",
      "uvhm",
      "uvhs",
      "uvh264",
      "uvmp4",
      "uvv",
      "uvvx",
      "uvvy",
      "3gp",
      "3g2",
      "3gp2",
      "3gpp",
      "amv",
      "asf",
      "asx",
      "cmv",
      "drc",
      "dsm",
      "dvx",
      "evo",
      "flc",
      "fli",
      "flic",
      "flv",
      "gxf",
      "h264",
      "m264",
      "m4u",
      "m4e",
      "m4b",
      "m4r",
      "m4a",
      "m4p",
      "m4v",
      "mkv",
      "mka",
      "mks",
      "mk3d",
      "mxf",
      "nsv",
      "nuv",
      "nxs",
      "pva",
      "pvf",
      "pvf2",
      "qtm",
      "ram",
      "rmvb",
      "rpm",
      "smk",
      "swf",
      "tmv",
      "tvi",
      "ty",
      "vfw",
      "viv",
      "vro",
      "wm",
      "wmv",
      "wmx",
      "wvx",
      "yuv"
    ];
    return videoExtensions.contains(lowName);
  }
}
