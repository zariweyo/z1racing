import 'dart:convert';

import 'package:nakama/nakama.dart';

class NakamaRepository {
  late NakamaBaseClient client;
  Session? session;
  NakamaWebsocketClient? socket;

  static testCreate() async {
    NakamaRepository repo = NakamaRepository();
    repo.connect();
    await repo.authenticate("userIdCA1");
    repo.initSocket();
    await repo.createMatch();
    print("MATCH CREATED!!");
  }

  static testJoin() async {
    NakamaRepository repo = NakamaRepository();
    repo.connect();
    await repo.authenticate("userIdCA2");
    repo.initSocket();
    await repo.joinMatch();
    print(repo.client);
    print(repo.session);
  }

  connect() {
    try {
      this.client = getNakamaClient(
        host: '192.168.1.41',
        ssl: false,
        serverKey: 'defaultkey',
        grpcPort: 7349, // optional
      );
    } catch (e) {
      print(e);
    }
  }

  authenticate(String id) async {
    try {
      this.session = await this.client.authenticateCustom(id: id);

      print('Hey, you are logged in! UserID: ${this.session!.userId}');
    } catch (e) {
      print(e);
    }
  }

  refreshSession() async {
    if (session == null) {
      return;
    }
    final inOneHour = DateTime.now().add(Duration(hours: 1));

    // Check whether a session has expired or is close to expiry.
    if (session!.isExpired || session!.hasExpired(inOneHour)) {
      try {
        // Attempt to refresh the existing session.
        session = await client.sessionRefresh(session: this.session!);
      } catch (e) {
        // Couldn't refresh the session so reauthenticate.
        session = await client.authenticateDevice(deviceId: "sdfsdfsdf");
      }
    }
  }

  getData() async {
    assert(session != null);
    final account = await client.getAccount(this.session!);
    /* final username = account.user.username;
    final avatarUrl = account.user.avatarUrl;
    final userId = account.user.id; */
  }

  initSocket() {
    assert(session != null);
    try {
      this.socket = NakamaWebsocketClient.init(
        host: '127.0.0.1',
        ssl: false,
        token: this.session!.token,
      );
    } catch (e) {
      print(e);
    }
  }

  Future createMatch() async {
    assert(socket != null);
    try {
      var match = await this.socket!.createMatch("num1");
      print(match);
      var matchJoin =
          await this.socket!.joinMatch("b2635835-71cb-5c91-a15e-81a2579fb9d9.");
      print(matchJoin);
      this.socket!.onMatchData.listen((data) {
        print("Message RECEIVED!!!!");
        print(data);
      });
    } catch (e) {
      print(e);
    }
  }

  Future joinMatch() async {
    assert(session != null);
    assert(socket != null);
    try {
      //var matches = await this.client.listMatches(session: this.session!);
      //print(matches);
      var match =
          await this.socket!.joinMatch("b2635835-71cb-5c91-a15e-81a2579fb9d9.");
      print(match);
      print(match.runtimeType);
      var dataJson = {"param1": "value1"};
      List<int> data = utf8.encode(dataJson.toString());
      //this.socket!.close();
      var result = await this
          .socket!
          .sendMatchData(matchId: "num1", opCode: Int64.TWO, data: data);
      print(result);
    } catch (e) {
      print(e);
    }
  }
}
