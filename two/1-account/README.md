# 1-account

계정 nalbam-two 전체에 적용하는 기본 설정입니다. 다른 root보다 먼저 적용합니다.

| 리소스 | 용도 |
| --- | --- |
| IAM account alias `nalbam-two` | 로그인 화면과 콘솔에 계정 ID 대신 보이는 이름 |
| S3 account public access block | 계정의 모든 bucket에서 public ACL·public policy를 막는다 |
| EBS encryption by default(`ap-northeast-2`) | 새 EBS volume(EB instance의 root volume 등)을 AWS 관리 키 `aws/ebs`로 암호화한다. 기존 volume은 바뀌지 않는다 |
| state bucket versioning | `terraform-workshop-552292899126`의 versioning. 잘못 덮어쓰거나 지운 state를 이전 version으로 되돌린다 |

state bucket 자체는 첫 root보다 먼저 있어야 하므로 Terraform이 만들지 않습니다([준비와 실행](../../README.md#준비와-실행)).

## 위험

- public access block이 켜져 있으면 public bucket(정적 웹사이트 등)을 만들 수 없습니다. 필요하면 CloudFront와 private bucket을 씁니다.
- EBS 기본 암호화는 리전 설정입니다. 다른 리전에서 instance를 쓰면 그 리전에도 따로 켜야 합니다.
- versioning을 켠 bucket은 끌 수 없고 일시 중지만 할 수 있습니다. 이전 version도 저장 비용이 듭니다(state는 작습니다).
