# buichadon

VRC やってる・興味ある人向けの Mastodon インスタンス、ぶいちゃどん（仮称）の構成を管理しているリポジトリ。

TODO:
- 構成図貼る
- Terraform 書く
  - RDS(PostgreSQL), S3, ElastiCache(Redis)
  - 一応スケールするようにしておく
  - Cloudfront でいい感じにキャッシュする
