# geta6.net

## 監視するディレクトリ

`/media/var`

`config/app.coffee`に直書きしてある、`process.env.ROOT_DIR`を修正する。

## 起動

`nodectl`

フックすべきファイルは`package.json: main`に書いてある

## ポート

`3030`、`package.json: port`

## ユーザ認証

* `PAM`を使用する
* 要Python、`pip install draxoft.auth.pam`

### 変更する

* `helper/authenticate.coffee`がcallbackに`true`を返すようにすればいい
* ssh-keyを保存しようとするので、`events/UserEvent.coffee`の`session.create`を修正する

## 問題点

* sessionハンドル時に`connect-stream`がエラーを吐く
* `nodectl restart`がうまく作動しない

