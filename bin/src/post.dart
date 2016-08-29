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

  Future<bool> save() async {
    if (_fromExisting) {
      // update post
    } else {
      // insert post
    }
    return false;
  }

}
