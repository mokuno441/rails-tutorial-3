
# Rails チュートリアル3週目
- ruby と rails のバージョンは [Railsチュートリアル](https://railsguides.jp/getting_started.html) のバージョンに合わせた

## 環境構築
1. docker イメージ作成
    ```bash
    docker build . -t rails
    ```
2. docker コンテナ起動してバインドマウントする
    ```bash
    mkdir blog && docker run -it --name rails-3 --mount type=bind,source="$(pwd)"/blog,target=/app/blog -p 3000:3000 rails bash
    ```
3. nokogiri の gem install エラー対策に設定を追加する
    ```bash
    bundle config set force_ruby_platform true
    ```
3. rails プロジェクト作成
    ```bash
    bundle config set path 'vendor/bundle' && rails new blog
    ```
4. サーバー起動
    ```bash
    blog/bin/rails server -b 0.0.0.0 -p 3000
    ```