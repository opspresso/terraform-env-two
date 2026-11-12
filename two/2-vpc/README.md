# 2-vpc

계정 nalbam-two의 VPC `vpc-two`(`10.20.0.0/16`)입니다. 지금은 Agent Runway eb target(`8-runway-target`)이 씁니다.

| 리소스 | 용도 |
| --- | --- |
| public subnet `vpc-two-public-a`·`-c` | internet-facing load balancer. instance에 public 주소를 자동으로 주지 않는다 |
| private subnet `vpc-two-private-a`·`-c` | public 주소가 없는 instance. 외부로는 NAT gateway로 나간다 |
| NAT gateway 1개(`a`)와 EIP | private subnet의 외부 통신. 주소는 output `nat_public_ips` |
| S3 gateway endpoint | private subnet의 S3 통신(EB source bundle, ECR image layer). NAT 처리 요금이 붙지 않는다 |
| 기본 security group | 규칙 없음. Elastic Beanstalk은 환경마다 security group을 만든다 |

argocd-env-projects `charts/delivery/files/eb-stack.yaml`이 instance에 public 주소를 주지 않으므로(`AssociatePublicIpAddress: false`)
private subnet에는 NAT가 필요하다. CIDR는 opspresso `eks-demo` VPC(`10.10.0.0/16`)와 겹치지 않는다.

## 비용과 위험

- 월 약 47 USD(ap-northeast-2, 730시간): NAT gateway 약 43 USD(시간당 0.059 USD)와 처리량 GB당 0.059 USD, EIP(public IPv4) 약 3.65 USD.
  VPC·subnet·S3 gateway endpoint는 비용이 없다.
- NAT gateway가 하나라서 AZ `a`에 장애가 나면 다른 AZ의 instance도 외부로 나가지 못한다. 실행 중인 앱은 계속 응답하지만 배포,
  Variable 읽기, image pull은 실패한다. AZ마다 NAT를 두면 NAT 비용이 AZ 수만큼 늘어난다(`nat_az`는 하나만 받는다).
- NAT instance(월 약 7 USD)는 OS 관리와 단일 instance 장애를 떠안으므로 쓰지 않는다. interface endpoint(ECR·SSM·Logs·Elastic Beanstalk·
  CloudFormation 등)는 AZ 2개 기준 NAT보다 비싸다.
- `az_subnets`의 key(AZ 문자)가 subnet 주소다. AZ를 빼면 그 subnet과 그 안의 EB 환경이 영향을 받는다.
