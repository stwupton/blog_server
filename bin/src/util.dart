part of blog.server;

// Postgresql database
Connection pgdb;

bool checkRequirements(
    Map data,
    {List required: const [],
    List optional: const [],
    bool purge: true}) {

  if (required.isNotEmpty) {
    for (var requirement in required) {
      if (!data.keys.contains(requirement))
        return false;
    }
  }

  if (purge) {
    data
      .keys.where((var key) => !required.contains(key) && !optional.contains(key))
      .toList().forEach(data.remove);
  }

  return true;

}

Map apiResponse(int code, [String message]) {

  if (code == -1)
    return {'code': -1, 'message': 'Requirements were not met.'};

  if (code == 0)
    return {'code': 0, 'message': 'Success'};

  Map response = {'code': code};
  if (message != null)
    response['message'] = message;

  return response;

}

Future<bool> validateCredentials(String username, String password) async {

  if (username == null || password == null)
    return false;

  Row row = await pgdb.query(
      'select username, password from admin where username = @username limit 1',
      {'username': username}).single;

  Map credentials = row.toMap();

  return new DBCrypt().checkpw(password, credentials['password']);

}
