part of blog.server;

class PostIndex {

  final bool draft;

  PostIndex({this.draft: false});

  List get({int year, int month}) async {

    if (month != null && year == null)
      throw 'Parameter `month` cannot be specified without `year`';

    if (month != null) {

      // return all post id's in month

    } else if (year != null) {

      // return all months in year

    } else if (draft) {

      // return all post ids

    } else {

      // return all years

    }

  }

}
