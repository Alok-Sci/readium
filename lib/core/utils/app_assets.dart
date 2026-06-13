class AppAssets {
  static String _getAssetPathByFilename(String filename) => 'assets/$filename';
  static String _getSvgAssetPath(String filename) => 'assets/svg_icons/$filename';

  // PNG assets
  static String get star => _getAssetPathByFilename('star-member-only.png');
  static String get delete => _getAssetPathByFilename('delete.png');
  static String get searchActive =>
      _getAssetPathByFilename('search-active.png');
  static String get search => _getAssetPathByFilename('search.png');
  static String get more => _getAssetPathByFilename('more.png');
  static String get following => _getAssetPathByFilename('following.png');
  static String get home => _getAssetPathByFilename('home.png');
  static String get profile => _getAssetPathByFilename('profile.png');
  static String get share => _getAssetPathByFilename('share.png');
  static String get setting => _getAssetPathByFilename('setting.png');
  static String get comment => _getAssetPathByFilename('comment.png');
  static String get articles => _getAssetPathByFilename('articles.png');
  static String get clap => _getAssetPathByFilename('clap.png');
  static String get listen => _getAssetPathByFilename('listen.png');
  static String get notification => _getAssetPathByFilename('notification.png');
  static String get redirect => _getAssetPathByFilename('redirect.png');

  // SVG assets
  static String get bookPublisherSvg => _getSvgAssetPath('book_publisher.svg');
  static String get clapOutlinedSvg => _getSvgAssetPath('clap_outlined.svg');
  static String get clapSvg => _getSvgAssetPath('clap.svg');
  static String get memberOnlySvg => _getSvgAssetPath('member_only.svg');
  static String get redirectToSvg => _getSvgAssetPath('redirect_to.svg');
  static String get responseOutlinedSvg => _getSvgAssetPath('response_outlined.svg');
  static String get responseSvg => _getSvgAssetPath('response.svg');
  static String get searchSvg => _getSvgAssetPath('search.svg');
  static String get shareSvg => _getSvgAssetPath('share.svg');
}
