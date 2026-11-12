# 3-domain

계정 nalbam-two의 public zone `two.rovr.dev`입니다. Agent Runway eb target `two-eb-amd64`(`8-runway-target`)의 앱 도메인이며,
앱 host는 `<slug>.two.rovr.dev`, `<slug>-<env>.two.rovr.dev`입니다.

부모 zone `rovr.dev`는 opspresso 계정에 있습니다. terraform-env-opsp `demo/8-app-delivery`의 `target_domains`가 이 zone의 name server로
NS 레코드를 만들어 위임합니다. zone을 다시 만들면 name server가 바뀌므로 `prevent_destroy`로 보호합니다. 비용은 월 0.50 USD와 query 요금입니다.

## 적용 순서

1. 이 디렉터리를 적용하고 name server를 읽는다.

   ```bash
   terraform output -json name_servers
   ```

2. terraform-env-opsp `demo/8-app-delivery`의 `target_domains`에 `"two.rovr.dev" = <name_servers>`를 넣고 적용한다(opspresso 자격 증명).
3. 위임을 확인한다. 그 뒤 `8-runway-target`의 인증서를 검증할 수 있다.

   ```bash
   dig +short NS two.rovr.dev
   ```
