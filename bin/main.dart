library blog.server;

import 'dart:async';
import 'dart:io';

import 'package:bliss/bliss.dart';

part 'src/post.dart';
part 'src/util.dart';

void main() {

  new Server(InternetAddress.ANY_IP_V6, 0)

    // Edit posts (admin)
    ..addHandler('POST', '/post', createPost)
    ..addHandler('PUT', '/post', updatePost)

    // Retrieve indexes and post data
    ..addHandler('GET', '/post/:year', () => null)
    ..addHandler('GET', '/post/:year/:month', () => null)
    ..addHandler('GET', '/post/:year/:month/:post_id', () => null)

    // Edit and retrieve drafts (admin)
    ..addHandler('POST', '/draft', () => null)
    ..addHandler('PUT', '/draft', () => null)
    ..addHandler('GET', '/draft', () => null)
    ..addHandler('GET', '/draft/:podt_id', () => null)

    ..start();

}

Future<Map> createPost(Map postData) async {

  if (!checkRequirements(postData, required: ['title', 'body']))
    return apiResponse(-1);

  Post post = new Post(postData['title'], postData['body']);

  if (!await post.save())
    return apiResponse(-2, 'Could not create new post.');
  else
    return apiResponse(0);

}

Future<Map> updatePost(Map postData) async {

  if (!checkRequirements(postData, required: ['id'], optional: ['title', 'body']))
    return apiResponse(-1);

  Post post = await Post.fromExisting(postData['id']);

  if (postData['title'] != null)
    post.title = postData['title'];

  if (postData['body'] != null)
    post.body = postData['body'];

  if (!await post.save())
    return apiResponse(-2, 'Could not create new post.');
  else
    return apiResponse(0);

}
