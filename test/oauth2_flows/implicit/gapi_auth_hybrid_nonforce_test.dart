// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:unittest/unittest.dart';
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:googleapis_auth/src/oauth2_flows/implicit.dart' as impl;
import 'package:googleapis_auth/src/utils.dart' as utils;

import 'utils.dart';

main() {
  impl.GapiUrl = resource('gapi_auth_hybrid_nonforce.js');

  test('gapi-auth-hybrid-nonforce-test', () {
    var clientId = new auth.ClientId('foo_client', 'foo_secret');
    var scopes = ['scope1', 'scope2'];

    auth.createImplicitBrowserFlow(clientId, scopes)
        .then(expectAsync((auth.BrowserOAuth2Flow flow) {

      flow.runHybridFlow(force: false).then(expectAsync((auth.HybridFlowResult result) {
        var credentials = result.credentials;

        var date = new DateTime.now().toUtc().add(const Duration(
            seconds: 3210 - utils.MAX_EXPECTED_TIMEDIFF_IN_SECONDS));
        var difference = credentials.accessToken.expiry.difference(date);
        var seconds = difference.inSeconds;

        expect(-3 <= seconds && seconds <= 3, isTrue);
        expect(credentials.accessToken.data, 'foo_token');
        expect(credentials.refreshToken, isNull);
        expect(credentials.scopes, hasLength(2));
        expect(credentials.scopes[0], 'scope1');
        expect(credentials.scopes[1], 'scope2');

        expect(result.authorizationCode, 'mycode');
      }));
    }));
  });
}
