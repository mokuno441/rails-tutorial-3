
# Rails チュートリアル3週目
- ruby と rails のバージョンは [Railsチュートリアル](https://railsguides.jp/getting_started.html) のバージョンに合わせた

## 環境構築
1. docker イメージ作成
    ```bash
    docker build . -t rails
    ```
2. docker コンテナ起動してバインドマウント
    ```bash
    mkdir blog && docker run -it --name rails-3 --mount type=bind,source="$(pwd)"/blog,target=/app/blog -p 3000:3000 rails bash
    ```
3. nokogiri の gem install エラー対策に設定を追加
    ```bash
    bundle config set force_ruby_platform true
    ```
3. rails プロジェクト作成
    ```bash
    bundle config set path 'vendor/bundle' && rails new .
    ```
4. サーバー起動
    ```bash
    bin/rails server -b 0.0.0.0 -p 3000
    ```
    Rails のページを表示できれば OK
5. 一旦サーバーを停止して、 rails の db を postgres に設定（rails new 時に指定も可）
    ```bash
    bin/rails db:system:change --to=postgresql && bundle install
    ```
6. rails-3 コンテナから抜けて postgres コンテナを作成
    ```bash
    docker run --name postgres -it -p 5432:5432 -e POSTGRES_PASSWORD=postgres -v "$(pwd)"/data:/var/lib/postgreslq/data -d postgres
    ```
7. コンテナ間通信のためにネットワークを作成して、コンテナを接続
    ```bash
    docker network create rails-3-to-postgres && docker network connect rails-3-to-postgres rails-3 && docker network connect rails-3-to-postgres postgres
    ```
8. ip アドレスの情報を確認
    ```bash
    docker network inspect rails-3-to-postgres
    # "Containers": {
    #   "1e1dcf8bf2cf0ca989d1d44e143db6fa86685bf823dca69f393c0ee812c0258d": {
    #       "Name": "postgres",
    #       ...
    #       "IPv4Address": "172.18.0.2/16",
    #       ...
    #   },
    #   "4cc9abbd90f5c6352ee7f70c2f6ade6e93850e864e5ce33f3a524653aa2c1a1c": {
    #       "Name": "rails-3",
    #       ...
    #       "IPv4Address": "172.18.0.3/16",
    #       ...
    #   }
    # }
    ```
9. `blog/config/database.yml` を編集し、 `host` に `postgres` の `IPv4Address` を設定
    ```yml
    default: &default
    adapter: postgresql
    encoding: unicode
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    host: 172.18.0.2
    port: 5432
    username: blog
    password: password

    development:
    <<: *default
    database: blog_development

    test:
    <<: *default
    database: blog_test

    production:
    <<: *default
    database: blog_production
    ```
10. `postgres` コンテナに入る
    ```bash
    docker exec -it postgres bash
    ```
11. sqlサーバーを起動し、ロール `blog` を作成
    ```bash
    /etc/init.d/postgresql start && su postgres && psql
    create role blog with createdb login password 'password'
    ```
12. `rails-3` コンテナから DB を作成
    ```bash
    docker exec -it rails-3 bash
    bin/rails db:create
    ```
13. 再び rails サーバー起動
    ```bash
    bin/rails server -b 0.0.0.0 -p 3000
    ```

以上

- 参考
    - postgres で `psql: could not connect to server: No such file or directory
        Is the server running locally and accepting
        connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?` の解消、および  `createuser: could not connect to database postgres: FATAL:  role "root" does not exist` の解消
        - https://qiita.com/sibakenY/items/407b721ad1bd0975bd00