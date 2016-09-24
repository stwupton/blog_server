part of blog.server;

class PostIndex {

  final bool draft;

  PostIndex({this.draft: false});

  Future<List> get({int year, int month}) async {

    if (month != null && year == null)
      throw 'Parameter `month` cannot be specified without `year`';

    if (month != null) {

      List<Map> ids = [];
      await for (Row row in pgdb.query(
          'select id, published from posts where (year, month) = (@year, @month) order by published asc',
          {'year': year, 'month': month}))
        ids.add(row[0]);

      return ids;

    } else if (year != null) {

      List<int> months = [];
      await for (Row row in pgdb.query(
          'select distinct month from posts where year = @year order by month asc',
          {'year': year}))
        months.add(row[0]);

      return months;

    } else if (draft) {

      List<int> ids = [];
      await for (Row row in pgdb.query('select id from drafts'))
        ids.add(row[0]);

      return ids;

    } else {

      List<int> years = [];
      await for (Row row in pgdb.query('select distinct year from posts order by year asc'))
        years.add(row[0]);

      return years;

    }

  }

}
