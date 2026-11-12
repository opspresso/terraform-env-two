# terraform-env-two

계정 nalbam-two(`552292899126`, `ap-northeast-2`)의 AWS 리소스를 관리합니다. 이 계정은 Agent Runway 환경 `two`의 앱을 실행합니다.
Agent Runway와 그 설치 계정 opspresso(`396608815058`)의 리소스는 [terraform-env-opsp](https://github.com/opspresso/terraform-env-opsp)가 관리합니다.
`two/`의 각 디렉터리는 독립된 Terraform root입니다.

| 디렉터리 | 용도 |
| --- | --- |
| [2-vpc](two/2-vpc/README.md) | VPC `vpc-two`: public·private subnet, NAT gateway 1개, S3 gateway endpoint |
| [3-domain](two/3-domain/README.md) | public zone `two.rovr.dev`. opspresso `rovr.dev`가 위임한다 |
| [8-runway-target](two/8-runway-target/README.md) | Agent Runway 환경 `two`의 `eb` target `two-eb-amd64`: 인증서 `*.two.rovr.dev`, Variable KMS key, deploy·secrets 역할, app boundary, EB 서비스 역할, source bundle bucket |

처음 적용할 때의 순서는 다음과 같습니다. opspresso 쪽 변경은 terraform-env-opsp `demo/8-app-delivery`에 있습니다.

1. `2-vpc`, `3-domain`
2. terraform-env-opsp `demo/8-app-delivery`: `two.rovr.dev` NS 위임(`3-domain`의 `name_servers`)과 ECR pull 허용
3. Agent Runway 환경 `two` 생성(External ID 발급), 그 뒤 `8-runway-target`
4. Agent Runway 환경 `two`에 `eb` target 추가

## 디렉터리 이름

root는 `two/<NN>-<주제>`입니다. `two`는 이 계정을 쓰는 Agent Runway 환경 이름이며, terraform-env-opsp의 `demo/`(설치 `eks-demo`)와 같은 자리입니다.
번호는 terraform-env-demo·terraform-env-opsp와 같은 의존 순서를 따릅니다: `2` 네트워크, `3` DNS, `8` 서비스별 리소스. 번호가 작은 root를 먼저 적용합니다.

## 준비와 실행

Terraform `1.17.1`, AWS CLI, nalbam-two 계정의 자격 증명이 필요합니다. 코드는 profile 이름을 정하지 않습니다. AWS SSO로 로그인한 뒤 환경변수로 profile을 고릅니다.
provider는 `allowed_account_ids`로 nalbam-two만 받으므로 다른 계정의 자격 증명이면 plan이 시작하지 않습니다.

```bash
aws sso login --profile nalbam-two
export AWS_PROFILE=nalbam-two
cd two/<root>
terraform init
terraform fmt -check
terraform validate
terraform plan
```

plan에서 예상한 변경만 있는지 확인한 뒤 `terraform apply`를 실행합니다. AWS 리소스나 데이터를 삭제하기 전에는 영향을 별도로 확인합니다.

state는 이 계정의 S3 bucket `terraform-workshop-552292899126`에 `backend/two/<이름>-two/terraform.tfstate`로 저장합니다. `default` workspace를 씁니다.
S3 잠금(`use_lockfile = true`)을 쓰므로 state 객체와 `.tflock` 객체를 읽고 쓰고 지울 권한이 필요합니다. backend key는 임의로 바꾸지 마세요.

## Terraform 작성 규칙

`two/`의 모든 root는 같은 파일 배치와 작성 규칙을 따릅니다. 규칙은 terraform-env-opsp와 같습니다. `scripts/check-layout.sh`가 파일 배치를 검사하고, CI가 이 스크립트와 `terraform fmt -check`·`terraform validate`를 실행합니다.

### 파일 이름

파일 이름은 `NN-<주제>.tf`입니다. `NN`은 두 자리 숫자이고, 주제는 소문자·숫자·`-`로 씁니다.

| 파일 | 담는 블록 |
| --- | --- |
| `00-variables.tf` | 모든 `variable`. `variable`이 없는 root에는 두지 않습니다 |
| `02-backend.tf` | `terraform`(`required_version`·`backend`·`required_providers`)과 `provider` |
| `02-remote-state.tf` | `data "terraform_remote_state"` |
| `03-data.tf` | 여러 파일이 함께 쓰는 `data` |
| `03-locals.tf` | 여러 파일이 함께 쓰는 `locals`와 `default_tags`용 `local.tags` |
| `04-`~`98-<주제>.tf` | 주제별 리소스와 그 주제의 `data`·`locals`. 의존 순서대로 번호를 붙이고, 한 주제를 여러 파일로 나누면 같은 번호를 씁니다 |
| `99-outputs.tf` | 모든 `output` |

각 root에는 `required_version`과 같은 값의 `.terraform-version`을 둡니다.

### 코드

- `required_version`과 provider `version`은 정확한 버전으로 고정합니다(예: `"1.17.1"`, `"6.71.0"`). 범위 지정은 쓰지 않습니다. 다른 저장소의 module은 commit SHA(`?ref=<SHA>`)로 고정합니다.
- S3 backend는 `encrypt = true`와 `use_lockfile = true`를 씁니다.
- AWS provider는 `allowed_account_ids = [var.account_id]`로 계정을 확인하고, `default_tags { tags = local.tags }`로 태그를 붙입니다. `local.tags`는 `03-locals.tf`에 둡니다.
- `variable`에는 `description`과 `type`을 씁니다.
- 파일마다 `locals` 블록은 하나만 둡니다. 본문이 없는 블록은 `data "aws_caller_identity" "current" {}`처럼 한 줄로 씁니다.
- 주석은 코드만으로 알 수 없는 이유·제약·외부 연결을 설명합니다. 파일 이름이나 블록 종류를 반복하는 머리 주석(`# variable`, `# output` 등)은 쓰지 않습니다.
- 파일 이름을 바꾸거나 블록을 다른 파일로 옮겨도 state 주소는 바뀌지 않습니다. 리소스 이름을 바꾸거나 module로 옮길 때는 `moved` 블록을 함께 씁니다.
- 공개 저장소입니다. 비밀 값과 Agent Runway의 External ID는 커밋하지 않고 환경변수(`TF_VAR_*`)나 미추적 `*.tfvars`로 줍니다.
