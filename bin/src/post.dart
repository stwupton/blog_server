part of blog.server;

class Post {

  String title,
         body,
         _id;
  final bool draft;

  bool get _fromExisting => _id != null;

  Post(this.title, this.body, {this.draft: false});

  Post._existing(this.title, this.body, this._id, this.draft);

  static Future<Post> fromExisting(String postId, {bool draft: false}) async {

    // query database for post
    Map post;
    return new Post._existing(post['title'], post['body'], post['id'], draft);

  }

  Future<bool> delete() async {

    if (!_fromExisting)
      return false;

    // delete post from db

    return true;

  }

  Future<bool> save() async {
    if (_fromExisting) {
      // update post
    } else {
      // insert post
    }
    return false;
  }

  Map toMap() {

    if (!_fromExisting)
      throw 'Post does not exist yet, it first needs to be saved.';

    return {
      'id': _id,
      'title': title,
      'body': body,
      // 'created': created,
      // 'updated': updated
    };

  }

}
