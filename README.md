
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
5. db 作成
    ```bash
    docker run --name postgres -it -p 5432:5432 -e POSTGRES_PASSWORD=postgres -v "$(pwd)"/data:/var/lib/postgreslq/data -d postgres
    ```
6. 一旦サーバーを停止して、 rails の db を postgres に設定（rails new 時に指定も可）
    ```bash
    bin/rails db:system:change --to=postgresql && bundle install
    ```
7. コンテナ間通信のためにネットワークを作成して、コンテナを接続
    ```bash
    docker network create rails-3-to-postgres && docker network connect rails-3-to-postgres rails-3 && docker network connect rails-3-to-postgres postgres
    ```
