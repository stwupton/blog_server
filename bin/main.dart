library blog.server;

import 'dart:async';
import 'dart:io';

import 'package:bliss/bliss.dart';
import 'package:postgresql/postgresql.dart';

part 'src/post.dart';
part 'src/post_index.dart';
part 'src/util.dart';

Future main() async {

  // Initialise database connection.
  pgdb = await connect(Platform.environment['DATABASE_URL']);

  new Server(InternetAddress.ANY_IP_V6, 8080)

    // Edit posts (admin)
    ..addHandler('POST', '/post', createPost)
    ..addHandler('PUT', '/post/:id', updatePost)
    ..addHandler('DELETE', '/post/:id', deletePost)

    // Retrieve indexes and post data
    ..addHandler('GET', '/post/index/:year', getIndex)
    ..addHandler('GET', '/post/index/:year/:month', getIndex)
    ..addHandler('GET', '/post/:id', getPost)

    // Edit and retrieve drafts (admin)
    ..addHandler('POST', '/draft', (Map data) => createPost(data, draft: true))
    ..addHandler('PUT', '/draft/:id', (Map data) => updatePost(data, draft: true))
    ..addHandler('DELETE', '/draft/:id', (Map data) => deletePost(data, draft: true))
    ..addHandler('GET', '/draft/index', (Map data) => getIndex(data, draft: true))
    ..addHandler('GET', '/draft/:id', (Map data) => getPost(data, draft: true))

    ..start();

}

Future<Map> createPost(Map postData, {bool draft: false}) async {

  if (!checkRequirements(postData, required: ['title', 'body']))
    return apiResponse(-1);

  Post post = new Post(postData['title'], postData['body'], draft: draft);

  if (!await post.save())
    return apiResponse(-2, 'Could not create new post.');
  else
    return apiResponse(0);

}

Future<Map> deletePost(Map postData, {bool draft: false}) async {

  Post post = await Post.fromExisting(postData['id'], draft: draft);

  if (post == null)
    return apiResponse(-2, 'Post does not exist.');

  if (!await post.delete())
    return apiResponse(-3, 'Could not delete post.');
  else
    return apiResponse(0);

}

Future<Map> getIndex(Map searchData, {bool draft: false}) async {

  PostIndex index = new PostIndex(draft: draft);
  return {
    'index': await index.get(year: searchData['year'], month: searchData['month']),
  }..addAll(apiResponse(0));

}

Future<Map> getPost(Map postData, {bool draft: false}) async {

  Post post = await Post.fromExisting(postData['id'], draft: draft);

  if (post == null)
    return apiResponse(-2, 'Post does not exist.');

  return post.toMap()..addAll(apiResponse(0));

}

Future<Map> updatePost(Map postData, {bool draft: false}) async {

  if (!checkRequirements(postData, required: ['id'], optional: ['title', 'body']))
    return apiResponse(-1);

  Post post = await Post.fromExisting(postData['id'], draft: draft);

  if (post == null)
    return apiResponse(-2, 'Post does not exist.');

  if (postData['title'] != null)
    post.title = postData['title'];

  if (postData['body'] != null)
    post.body = postData['body'];

  if (!await post.save())
    return apiResponse(-3, 'Could not update post.');
  else
    return apiResponse(0);

}
