part of blog.server;

class Post {

  String title;
  String body;
  String _id;

  bool get _fromExisting => _id != null;

  Post(this.title, this.body);

  Post._existing(this.title, this.body, this._id);

  static Future<Post> fromExisting(String postId) async {

    // query database for post
    Map post;
    return new Post._existing(post['title'], post['body'], post['id']);

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
