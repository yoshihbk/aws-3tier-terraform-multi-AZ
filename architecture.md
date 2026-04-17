# Architecture Details

本ドキュメントでは、本プロジェクトで構築した  
**AWS 3-Tier Architecture（Multi-AZ + Read Replica）** の技術的詳細を記述します。

---

## 1. 全体構成

本アーキテクチャは以下の 3 層で構成されています。

- **Web Tier**：ALB（Application Load Balancer）
- **Application Tier**：Auto Scaling Group（EC2, nginx）
- **Database Tier**：RDS（Multi-AZ + Read Replica）

本プロジェクトでは、  
アプリケーションは **静的 HTML を返すのみ** であり、  
RDS へのデータ参照は行いません。(通信が通るのみ)

---

## 2. ネットワーク構成（VPC）

- VPC：10.0.0.0/16
- Public Subnet（2AZ）
  - ALB
  - NAT Gateway
- Private Subnet（2AZ）
  - EC2（ASG）
- Private Subnet（DB 用）
  - RDS Primary（Multi-AZ）
  - RDS Read Replica

---

## 3. Web Tier（ALB）

- Application Load Balancer を 2AZ に配置
- HTTPを受け付け、ASG の EC2 にルーティング
- ヘルスチェックにより異常インスタンスを自動除外

---

## 4. Application Tier（EC2 + ASG）

- Auto Scaling Group により 2AZ に EC2 を分散配置
- EC2 上では **nginx が静的 HTML を返す**
- インスタンス障害時は自動復旧
- user_data により EC2 起動時に nginx を自動セットアップ

---

## 5. Database Tier（RDS）

- RDS MySQL（Multi-AZ）
  - Primary：AZ-a
  - Standby：AZ-c（自動フェイルオーバー）
- Read Replica（読み取り専用）
  - 構成として冗長性を確保  
  - ※Webページ版では DB を参照しないため読み取り分離は未使用

---

## 6. セキュリティ設計

- Public Subnet のみインターネットアクセス可能
- Private Subnet の EC2 は NAT 経由で外部通信
- RDS は Private Subnet 内に隔離
- Security Group により最小権限アクセスを実現
  - ALB → EC2（80）
  - EC2 → RDS（3306）
  - 外部から RDS への直接アクセス不可

---

## 7. IaC（Terraform）

- 全リソースを Terraform でコード化
- `terraform apply` のみで再現可能
- tfstate による状態管理

---

## 8. 冗長性と可用性

- **Multi-AZ**：AZ 障害時もサービス継続
- **ASG**：EC2 障害時の自動復旧
- **ALB**：負荷分散とヘルスチェック
- **Read Replica**：構成上の冗長性を実現

---

以上が本アーキテクチャの技術詳細です。
