# 8-runway-target

Agent Runway 계정 `nalbam-two`와 그 계정의 환경 `two`(`eb` target)이 쓰는 리소스입니다. Agent Runway는 opspresso 계정(`396608815058`)의 `eks-demo`에서 실행됩니다.
계약은 agent-platform `docs/APP_DELIVERY.md`의 "계정"이고, 배포 workflow는 argocd-env-projects `charts/delivery/files/app-deploy-eb.yaml`·
`app-remove-eb.yaml`·`eb-stack.yaml`입니다.

| 리소스 | 용도 |
| --- | --- |
| ACM 인증서 `*.two.rovr.dev` | load balancer HTTPS listener(`certificateArn`). `3-domain` zone의 DNS 레코드로 검증한다 |
| KMS `alias/agent-runway` | SecureString Variable 암호화(`secretsKeyArn`). `prevent_destroy`로 보호한다. 키를 지우면 저장한 비밀 Variable을 잃는다 |
| module `runway_target` | terraform-env-opsp `modules/runway-target`(commit SHA로 고정): app boundary `agent-runway-app-boundary`, deploy role `agent-runway-target-deploy`, EB 서비스 역할 `agent-runway-eb-service`, bucket `agent-runway-two-eb-amd64-552292899126`, secrets 역할 `agent-runway-target-secrets` |

두 역할은 opspresso의 역할(terraform-env-opsp `demo/7-eks-shared`)만 신뢰하고, 둘 다 Agent Runway가 만든 External ID(`sts:ExternalId`)를 요구합니다.

| 역할 | 넘겨받는 주체 | 하는 일 |
| --- | --- | --- |
| `agent-runway-target-deploy` | `pod-role--delivery-target`(`app-deploy-eb`·`app-remove-eb` 스텝) | session tag가 가리키는 Project 환경의 stack `runway-<project>-<env>`만 만들고 바꾼다 |
| `agent-runway-target-secrets` | `pod-role--agent-runway`(Agent Runway) | `environment_names`의 환경마다 `/agent-runway/<환경>/*` Variable을 이 계정의 KMS key로 쓰고 읽고 지운다. 접근 확인 경로 `/agent-runway/_runway/*`를 쓰고, 콘솔 선택지(VPC·subnet·인증서·hosted zone·EKS·EB 플랫폼)를 조회한다 |

native Java 플랫폼의 환경 secret 참조는 instance의 `ssm:GetParameter` 권한을 사용하며, 자기 환경 경로로 제한됩니다.

기존 Docker 앱 이미지는 opspresso ECR `projects/<slug>`에 있습니다. terraform-env-opsp `demo/8-app-delivery`의 registry policy가 이 계정의 instance 역할 `runway-*-app`의 pull을 허용합니다.

출력 `account`와 `eb_target`은 관리자가 Agent Runway 환경 `two`에 넣을 값입니다(비밀 값 없음). Agent Runway는 `account.access.externalId`를 직접 정합니다.

## 네트워크

이 계정은 따로 VPC를 만들지 않고 리전 `ap-northeast-2`의 기본 VPC를 씁니다. 출력 `eb_target`의 `vpcId`는 기본 VPC이고, `instanceSubnets`와
`loadBalancerSubnets`는 같은 값(AZ마다 하나인 기본 subnet 전부)입니다.

- 기본 subnet은 public입니다. internet gateway route가 있고 NAT는 없습니다.
- 두 subnet 목록이 같으면 배포 step이 instance에 public IP를 줍니다(argocd-env-projects `charts/delivery/files/target.sh` `public_ip`).
  instance는 그 주소로 ECR, Elastic Beanstalk, CloudFormation, SSM, CloudWatch Logs, S3에 연결합니다.
- instance security group은 Elastic Beanstalk이 만들고 load balancer에서 오는 요청만 받습니다. public IP로 instance에 직접 들어오는 경로는 없습니다.
- 비용: NAT gateway가 없습니다. instance마다 public IPv4 요금(시간당 0.005 USD, 월 약 3.65 USD)이 붙습니다.
- 기본 VPC를 지우면 이 root의 plan이 실패합니다. 다시 만들려면 `aws ec2 create-default-vpc`를 실행합니다.

## 준비

- `1-account`, `3-domain`을 먼저 적용합니다. 이 root는 `3-domain`의 state를 읽습니다.
- terraform-env-opsp `demo/8-app-delivery`가 `two.rovr.dev`를 위임해야 합니다. 위임이 없으면 인증서 검증이 끝나지 않습니다.
- `runway_external_id`가 필요합니다. 값은 Agent Runway 콘솔 **관리 > 계정 > nalbam-two**의 External ID입니다. 공개 저장소이므로 Git에 넣지 않고
  `TF_VAR_runway_external_id` 환경변수나 미추적 `terraform.tfvars`로 줍니다. 값이 없으면 plan이 시작하지 않습니다.

## 적용 순서

1. Agent Runway 관리자가 콘솔 **관리 > 계정 > 계정 추가**에서 계정을 만듭니다. 이름 `nalbam-two`, 계정 ID `552292899126`, 리전 `ap-northeast-2`,
   **역할로 접근**을 켜고 secrets 역할 `arn:aws:iam::552292899126:role/agent-runway-target-secrets`를 넣습니다. Agent Runway가 External ID를 만듭니다.
   trust policy에 아직 External ID가 없으므로 이때의 접근 확인은 실패합니다.
2. 이 디렉터리를 적용합니다. 인증서 검증은 몇 분 걸릴 수 있습니다.

   ```bash
   export AWS_PROFILE=nalbam-two TF_VAR_runway_external_id=<External ID>
   terraform init
   terraform plan
   terraform apply
   terraform output -json account
   ```

3. 관리자가 계정 `nalbam-two`에 출력 `account`의 `artifactBucket`·`secretsKeyArn`을 넣어 저장하고 **접근 확인**을 누릅니다. 성공하면 `verifiedAt`이 기록됩니다.
   실패하면 화면의 오류를 확인하고 고친 뒤 다시 확인합니다.
4. 관리자가 **관리 > 환경 > 환경 추가**에서 계정 `nalbam-two`, 종류 VM을 고르고 VPC·subnet·인증서·hosted zone·플랫폼을 고릅니다. 선택지는 계정에서 조회됩니다.
   값은 출력 `eb_target`과 같습니다. 환경 이름은 `environment_names`에 있어야 합니다. 다른 이름이면 그 이름을 더해 다시 적용합니다.

## 비용과 위험

- 이 root의 고정 비용은 KMS key 월 1 USD와 S3 저장 비용입니다. EB 환경마다 ALB(시간당 약 0.0225 USD와 LCU), ALB public IPv4 2개, instance 비용이 따로 듭니다.
- `AdministratorAccess-AWSElasticBeanstalk`는 계정의 모든 EB 애플리케이션에 닿습니다. 그 위의 Deny(`runway-isolation`)가 session을 자기 Project 환경으로 제한합니다.
  이 계정에서는 Agent Runway가 아닌 EB 애플리케이션을 운영하지 않습니다.
- module을 바꾸려면 terraform-env-opsp에서 먼저 바꾸고 `30-target.tf`의 `ref`를 그 commit SHA로 올립니다.
