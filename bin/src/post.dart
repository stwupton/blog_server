part of blog.server;

class Post {

  static const String INSERT_VALUE_LIST   = '(id, title, body, updated, published, year, month) values (@id, @title, @body, @updated, @published, @year, @month)',
                      INSERT_VALUE_LIST_D = '(id, title, body, updated) values (@id, @title, @body, @updated)',
                      UPDATE_VALUE_LIST   = '(title, body, updated) = (@title, @body, @updated)';

  String title, body, _id;
  DateTime published, updated;
  final bool draft;

  bool get _fromExisting => _id != null;
  String get _table => draft ? 'drafts' : 'posts';

  Post(this.title, this.body, {this.draft: false});

  Post._existing(this.title, this.body, this._id, this.updated, this.published, this.draft);

  static Future<Post> fromExisting(String postId, {bool draft: false}) async {

    String table = draft ? 'drafts' : 'posts';

    Row row;
    await for (Row r in pgdb.query('select * from $table where id = @id', {'id': postId})) {
      row = r;
      break;
    }

    if (row == null)
      return null;

    Map post = row.toMap();

    return new Post._existing(
        post['title'],
        post['body'],
        post['id'],
        post['updated'],
        post['published'],
        draft);

  }

  Future<bool> delete() async {

    if (!_fromExisting)
      return false;

    int affect = await pgdb.execute(
        'delete from $_table where id = @id',
        {'id': _id});

    return affect > 0;

  }

  String _idFromTitle(String title) {
    return title
      .toLowerCase()
      .replaceAll(' ', '-')
      .replaceAll(new RegExp('[^\\w-]'), '');
  }

  Future<bool> save() async {

    int affect;
    DateTime now = new DateTime.now().toUtc();

    if (_fromExisting) {

      affect = await pgdb.execute(
          'update $_table set $UPDATE_VALUE_LIST where id = @id', {
            'id': _id,
            'title': title,
            'body': body,
            'updated': now
          });

    } else {

      String valueList = draft ? INSERT_VALUE_LIST_D : INSERT_VALUE_LIST;
      String id = _idFromTitle(title);

      if ((await pgdb.query(
          'select exists(select 1 from $_table where id = @id)',
          {'id': id}).single)[0])
        return false;

      affect = await pgdb.execute(
          'insert into $_table $valueList', {
            'id': _idFromTitle(title),
            'title': title,
            'body': body,
            'published': now,
            'updated': now,
            'year': now.year,
            'month': now.month
          });

    }

    return affect > 0;

  }

  Map toMap() {

    if (!_fromExisting)
      throw 'Post does not exist yet, it first needs to be saved.';

    return {
      'id': _id,
      'title': title,
      'body': body,
      'published': published?.toString(),
      'updated': updated.toString()
    };

  }

}
