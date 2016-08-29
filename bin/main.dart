library blog.server;

import 'dart:async';
import 'dart:io';

import 'package:bliss/bliss.dart';

part 'src/post.dart';
part 'src/post_index.dart';
part 'src/util.dart';

void main() {

  new Server(InternetAddress.ANY_IP_V6, 0)

    // Edit posts (admin)
    ..addHandler('POST', '/post', createPost)
    ..addHandler('PUT', '/post', updatePost)
    ..addHandler('DELETE', '/post/:id', deletePost)

    // Retrieve indexes and post data
    ..addHandler('GET', '/post/:year', getIndex)
    ..addHandler('GET', '/post/:year/:month', getIndex)
    ..addHandler('GET', '/post/:id', getPost)

    // Edit and retrieve drafts (admin)
    ..addHandler('POST', '/draft', (Map data) => createPost(data, draft: true))
    ..addHandler('PUT', '/draft', (Map data) => updatePost(data, draft: true))
    ..addHandler('DELETE', '/draft/:id', (Map data) => deletePost(data, draft: true))
    ..addHandler('GET', '/draft', (Map data) => getIndex(data, draft: true))
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
  if (!await post.delete())
    return apiResponse(-2, 'Could not create new post.');
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
  Post post = await Post.fromExisting(postData['post_id'], draft: draft);
  return post.toMap()..addAll(apiResponse(0));
}

Future<Map> updatePost(Map postData, {bool draft: false}) async {

  if (!checkRequirements(postData, required: ['id'], optional: ['title', 'body']))
    return apiResponse(-1);

  Post post = await Post.fromExisting(postData['id'], draft: draft);

  if (postData['title'] != null)
    post.title = postData['title'];

  if (postData['body'] != null)
    post.body = postData['body'];

  if (!await post.save())
    return apiResponse(-2, 'Could not create new post.');
  else
    return apiResponse(0);

}
