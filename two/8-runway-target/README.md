# 8-runway-target

Agent Runway 환경 `two`의 `eb` target `two-eb-amd64`가 쓰는 리소스입니다. Agent Runway는 opspresso 계정(`396608815058`)의 `eks-demo`에서 실행됩니다.
계약은 agent-platform `docs/APP_DELIVERY.md`의 "외부 계정"이고, 배포 workflow는 argocd-env-projects `charts/delivery/files/app-deploy-eb.yaml`·
`app-remove-eb.yaml`·`eb-stack.yaml`입니다.

| 리소스 | 용도 |
| --- | --- |
| ACM 인증서 `*.two.rovr.dev` | load balancer HTTPS listener(`certificateArn`). `3-domain` zone의 DNS 레코드로 검증한다 |
| KMS `alias/agent-runway` | SecureString Variable 암호화(`secretsKeyArn`). `prevent_destroy`로 보호한다. 키를 지우면 저장한 비밀 Variable을 잃는다 |
| module `target` | terraform-env-opsp `modules/runway-target`(commit SHA로 고정): app boundary `agent-runway-app-boundary`, deploy role `agent-runway-target-deploy`, EB 서비스 역할 `agent-runway-eb-service`, bucket `agent-runway-two-eb-amd64-552292899126`, secrets 역할 `agent-runway-target-secrets` |

두 역할은 opspresso의 역할(terraform-env-opsp `demo/7-eks-shared`)만 신뢰하고, 둘 다 Agent Runway가 만든 External ID(`sts:ExternalId`)를 요구합니다.

| 역할 | 넘겨받는 주체 | 하는 일 |
| --- | --- | --- |
| `agent-runway-target-deploy` | `pod-role--delivery-target`(`app-deploy-eb`·`app-remove-eb` 스텝) | session tag가 가리키는 Project 환경의 stack `runway-<project>-<env>`만 만들고 바꾼다 |
| `agent-runway-target-secrets` | `pod-role--agent-runway`(Agent Runway) | `/agent-runway/two-eb-amd64/*` Variable을 이 계정의 KMS key로 쓰고 읽고 지운다 |

앱 이미지는 opspresso ECR `projects/<slug>`에 있습니다. terraform-env-opsp `demo/8-app-delivery`의 registry policy가 이 계정의 instance 역할 `runway-*-app`의 pull을 허용합니다.

출력 `account`와 `eb_target`은 관리자가 Agent Runway 환경 `two`에 넣을 값입니다(비밀 값 없음). Agent Runway는 `account.access.externalId`를 직접 정합니다.

## 준비

- `2-vpc`, `3-domain`을 먼저 적용합니다. 이 root는 두 state를 읽습니다.
- terraform-env-opsp `demo/8-app-delivery`가 `two.rovr.dev`를 위임해야 합니다. 위임이 없으면 인증서 검증이 끝나지 않습니다.
- `runway_external_id`가 필요합니다. 값은 Agent Runway 콘솔 **관리 > 환경 > two**의 External ID입니다. 공개 저장소이므로 Git에 넣지 않고
  `TF_VAR_runway_external_id` 환경변수나 미추적 `terraform.tfvars`로 줍니다. 값이 없으면 plan이 시작하지 않습니다.

## 적용 순서

1. Agent Runway 관리자가 환경 `two`를 target 없이 만듭니다. 첫 적용 전에는 `terraform output`이 없으므로 `account`를 직접 넣습니다.
   Agent Runway가 `account.access.externalId`를 만듭니다. machine target이 없으므로 접근 확인은 하지 않습니다.

   ```json
   {"name": "two", "cloud": "aws", "approval": "owner", "sandbox": false,
    "account": {"id": "552292899126", "region": "ap-northeast-2",
                "access": {"secretsRole": "arn:aws:iam::552292899126:role/agent-runway-target-secrets"}},
    "targets": []}
   ```

2. 이 디렉터리를 적용합니다. 인증서 검증은 몇 분 걸릴 수 있습니다.

   ```bash
   export AWS_PROFILE=nalbam-two TF_VAR_runway_external_id=<External ID>
   terraform init
   terraform plan
   terraform apply
   terraform output -json eb_target
   ```

3. 관리자가 환경 `two`에 출력 `eb_target`을 target으로 추가합니다. 저장할 때 Agent Runway가 접근을 확인하고 `verifiedAt`을 기록합니다.
   실패하면 응답의 `accessError`를 확인하고 고친 뒤 `POST /api/environments/two/access-check`를 요청합니다.

## 비용과 위험

- 이 root의 고정 비용은 KMS key 월 1 USD와 S3 저장 비용입니다. EB 환경마다 ALB(시간당 약 0.0225 USD와 LCU), ALB public IPv4 2개, instance 비용이 따로 듭니다.
- `AdministratorAccess-AWSElasticBeanstalk`는 계정의 모든 EB 애플리케이션에 닿습니다. 그 위의 Deny(`runway-isolation`)가 session을 자기 Project 환경으로 제한합니다.
  이 계정에서는 Agent Runway가 아닌 EB 애플리케이션을 운영하지 않습니다.
- module을 바꾸려면 terraform-env-opsp에서 먼저 바꾸고 `30-target.tf`의 `ref`를 그 commit SHA로 올립니다.
