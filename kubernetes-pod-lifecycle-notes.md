# Kubernetes Pod Lifecycle - నోట్స్ (తెలుగులో)

మూలం: https://devopscube.com/kubernetes-pod/#pod-lifecycle

## Pod అంటే ఏమిటి?

Kubernetes లో **Pod** అనేది అతి చిన్న deployable unit. ఒక Pod లో ఒకటి లేదా అంతకంటే ఎక్కువ containers ఉండొచ్చు, అవి ఒకే network మరియు storage share చేసుకుంటాయి.

## Pod Anatomy (Pod నిర్మాణం)

మూలం: Devopscube diagram

Kubernetes లో ఒక **Pod object** ప్రధానంగా 4 ప్రధాన భాగాలుగా విభజించబడుతుంది: **Metadata, Spec, Status, Events**.

### 1. Metadata (Pod యొక్క గుర్తింపు వివరాలు)

Pod ని identify చేయడానికి ఉపయోగపడే వివరాలు ఇవి:

- **Name** – Pod యొక్క పేరు.
  ```yaml
  metadata:
    name: my-app-pod
  ```
- **Namespace** – Pod ఏ namespace లో ఉందో సూచిస్తుంది (logical grouping కోసం).
  ```yaml
  metadata:
    namespace: dev
  ```
- **Labels** – Pod ని group చేయడానికి, select చేయడానికి (Services, Deployments వంటివి Pod ని ఎంచుకోవడానికి) వాడే key-value tags.
  ```yaml
  metadata:
    labels:
      app: my-app
      env: production
  ```
- **Annotation** – Pod గురించి extra, non-identifying information (tools/libraries కోసం metadata) store చేయడానికి వాడతారు.
  ```yaml
  metadata:
    annotations:
      description: "Frontend pod for checkout page"
  ```
- **Creation Timestamp** – Pod ఎప్పుడు create అయ్యిందో సూచించే timestamp.
  ```
  creationTimestamp: "2026-08-24T10:15:00Z"
  ```

### 2. Spec (Pod ఎలా run కావాలో నిర్వచించే భాగం)

Pod యొక్క desired state మరియు configuration ఇక్కడ define అవుతుంది:

- **Containers** – Pod లోపల run అయ్యే containers list.
  - **Images** – ప్రతి container ఏ container image నుండి run అవుతుందో సూచిస్తుంది.
    ```yaml
    containers:
      - name: web
        image: nginx:1.25
    ```
  - **Ports** – Container expose చేసే network ports.
    ```yaml
        ports:
          - containerPort: 80
    ```
  - **Lifecycle Hooks** – Container life లో specific సమయాల్లో run అయ్యే hooks:
    - **PostStart** – Container start అయిన వెంటనే run అయ్యే hook.
    - **PreStop** – Container terminate అవ్వడానికి ముందు run అయ్యే hook (graceful shutdown కోసం ఉపయోగపడుతుంది).
    ```yaml
        lifecycle:
          postStart:
            exec:
              command: ["echo", "Container Started"]
          preStop:
            exec:
              command: ["echo", "Container Stopping"]
    ```
- **Init Containers** – Main containers start అవ్వడానికి ముందు run అయ్యి, setup పనులు (dependencies, config వంటివి) పూర్తి చేసే containers.
  ```yaml
  initContainers:
    - name: wait-for-db
      image: busybox
      command: ["sh", "-c", "until nslookup db; do sleep 2; done"]
  ```
- **securityContext** – Container/Pod కి security settings (ఏ user గా run అవ్వాలి, privileges వంటివి) define చేస్తుంది.
  ```yaml
  securityContext:
    runAsUser: 1000
    runAsNonRoot: true
  ```
- **serviceAccountName** – Pod, Kubernetes API తో interact అవ్వడానికి వాడే service account పేరు.
  ```yaml
  serviceAccountName: my-app-service-account
  ```
- **resources** – Container కి కేటాయించే CPU/Memory requests మరియు limits.
  ```yaml
  resources:
    requests:
      cpu: "250m"
      memory: "128Mi"
    limits:
      cpu: "500m"
      memory: "256Mi"
  ```
- **probes** – Container health ని check చేయడానికి వాడే health checks (Liveness, Readiness, Startup probes).
  ```yaml
  livenessProbe:
    httpGet:
      path: /healthz
      port: 80
    initialDelaySeconds: 5
    periodSeconds: 10
  ```
- **Restart Policy** – Container fail అయినప్పుడు దాన్ని ఎలా restart చేయాలో నిర్ణయించే policy (Always, OnFailure, Never).
  ```yaml
  restartPolicy: Always
  ```
- **Volumes** – Pod కి attach అయ్యే storage volumes (containers మధ్య data share చేసుకోవడానికి లేదా persistent storage కోసం).
  ```yaml
  volumes:
    - name: shared-data
      emptyDir: {}
  ```
- **dnsPolicy** – Pod DNS resolution ఎలా చేయాలో నిర్ణయించే policy.
  ```yaml
  dnsPolicy: ClusterFirst
  ```
- **Affinity** – Pod ని ఏ nodes మీద schedule చేయాలో/చేయకూడదో నిర్ణయించే rules (Node affinity, Pod affinity/anti-affinity).
  ```yaml
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: disktype
                operator: In
                values: ["ssd"]
  ```
- **Tolerations** – Node లకు ఉన్న **taints** ని tolerate చేసి, ఆ nodes మీద Pod schedule అవ్వడానికి అనుమతించే settings.
  ```yaml
  tolerations:
    - key: "dedicated"
      operator: "Equal"
      value: "gpu"
      effect: "NoSchedule"
  ```

### 3. Status (Pod ప్రస్తుత స్థితి వివరాలు)

Runtime లో Pod యొక్క ప్రస్తుత స్థితిని చూపించే భాగం (ఇది `kubectl get pod <name> -o yaml` output లో `status:` కింద కనిపిస్తుంది):

- **Phase** – Pod యొక్క ప్రస్తుత lifecycle phase: `Running`, `Pending`, `Failed`, `Succeed` (వీటి వివరాలు క్రింద "Pod Lifecycle" సెక్షన్‌లో ఉన్నాయి).
  ```yaml
  status:
    phase: Running
  ```
- **Conditions** – Pod యొక్క వివిధ దశల్లో true/false గా ఉండే conditions:
  - **PodScheduled** – Pod ఒక node కి schedule అయ్యిందా అని సూచిస్తుంది.
  - **Initialized** – అన్ని Init Containers విజయవంతంగా పూర్తయ్యాయా అని సూచిస్తుంది.
  - **ContainersReady** – Pod లోని అన్ని containers ready గా ఉన్నాయా అని సూచిస్తుంది.
  - **Ready** – Pod మొత్తం traffic ని serve చేయడానికి సిద్ధంగా ఉందా అని సూచిస్తుంది.
  ```yaml
  status:
    conditions:
      - type: Ready
        status: "True"
  ```
- **Container status** – ప్రతి container యొక్క:
  - **Current state** (Waiting/Running/Terminated)
  - **Restart count** (ఆ container ఎన్నిసార్లు restart అయ్యిందో)
  ```yaml
  status:
    containerStatuses:
      - name: web
        state:
          running:
            startedAt: "2026-08-24T10:15:05Z"
        restartCount: 2
  ```
- **Host IP** – Pod run అవుతున్న node యొక్క IP address. ఉదా: `hostIP: 192.168.1.10`
- **Pod IP** – Pod కి కేటాయించిన internal IP address. ఉదా: `podIP: 10.244.0.5`
- **QoS class** – Pod యొక్క Quality of Service class (Guaranteed, Burstable, BestEffort) — resources requests/limits ఆధారంగా నిర్ణయించబడుతుంది. ఉదా: requests = limits అయితే → `qosClass: Guaranteed`
- **Start Time** – Pod ఎప్పుడు start అయ్యిందో సూచించే timestamp. ఉదా: `startTime: "2026-08-24T10:15:00Z"`

### 4. Events (Pod కి సంబంధించిన సంఘటనలు)

- Pod కి సంబంధించిన అన్ని events (scheduling, image pulling, errors వంటివి) list గా ఉంటాయి — వీటిని `kubectl describe pod <pod-name>` ద్వారా చూడొచ్చు.
  ```
  Events:
    Type    Reason     Age   From               Message
    ----    ------     ----  ----               -------
    Normal  Scheduled  10s   default-scheduler  Successfully assigned default/my-app-pod to node1
    Normal  Pulled     8s    kubelet            Container image "nginx:1.25" already present
    Normal  Started    7s    kubelet            Started container web
  ```
- ప్రతి Container తన life లో ఒక సాధారణ flow follow అవుతుంది: **Starts → Stops → Restarts** (అవసరమైతే Restart Policy ఆధారంగా).
  - ఉదా: `web` container start అవుతుంది → memory limit దాటడం వల్ల crash అయ్యి stop అవుతుంది → `restartPolicy: Always` వల్ల kubelet దాన్ని మళ్ళీ restart చేస్తుంది (restart count +1).

## Pod Lifecycle (Pod జీవితచక్రం)

Pod ఒక Pod గా create అయినప్పటి నుండి terminate అయ్యే వరకు వేర్వేరు **phases (దశలు)** గుండా వెళుతుంది. Kubernetes ఈ phase ని Pod యొక్క `status.phase` field లో చూపిస్తుంది.

మొత్తం **5 ప్రధాన phases** ఉంటాయి:

### 1. Pending
- Pod creation request విజయవంతంగా accept అయ్యింది, కానీ scheduling ఇంకా జరుగుతోంది.
- ఉదాహరణకు: container image ని download చేస్తున్న సమయంలో pod ఈ స్థితిలో ఉంటుంది.
- అంటే, Pod ని ఏ node కి schedule చేయాలో నిర్ణయించడం లేదా అవసరమైన resources సిద్ధం చేయడం జరుగుతుంది.

### 2. Running
- Pod విజయవంతంగా run అవుతూ, expected విధంగా పని చేస్తోంది.
- ఉదాహరణకు: Pod client requests కి service ఇస్తూ ఉండటం.
- Pod కనీసం ఒక container node కి bind అయి, run అవుతూ ఉంటే ఈ phase లో ఉంటుంది.

### 3. Succeeded
- Pod లోని containers అన్నీ విజయవంతంగా terminate (complete) అయ్యాయి.
- ఉదాహరణకు: ఒక CronJob object విజయవంతంగా పూర్తయినప్పుడు దాని Pod ఈ స్థితికి వెళుతుంది.
- ఇది restart అవసరం లేని, పూర్తయిన jobs కోసం వర్తిస్తుంది.

### 4. Failed
- Pod లోని containers అన్నీ terminate అయ్యాయి, కానీ వాటిలో కనీసం ఒక container **failure** తో terminate అయ్యింది (non-zero exit code తో).
- ఉదాహరణకు: application config issue వల్ల start కాలేక, container non-zero exit code తో exit అయినప్పుడు.

### 5. Unknown
- Pod యొక్క స్థితి Kubernetes కి తెలియదు.
- ఉదాహరణకు: cluster, node తో communication కోల్పోయి Pod status ని monitor చేయలేనప్పుడు ఈ phase వస్తుంది.

## Pod Phase ని ఎలా చూడాలి?

క్రింది command వాడి pod యొక్క ప్రస్తుత phase మరియు detailed status ని చూడొచ్చు:

```bash
kubectl describe pod <pod-name>
```

ఈ command output లో Pod యొక్క:
- Current phase (Pending/Running/Succeeded/Failed/Unknown)
- Container statuses
- Events (scheduling, image pull, start వంటి వివరాలు)

కనిపిస్తాయి.

## గమనిక (Note)

ఈ ఆర్టికల్‌లో pod lifecycle గురించి క్లుప్తంగా (5 phases) మాత్రమే వివరించారు. Container states (Waiting, Running, Terminated), Pod conditions, మరియు Restart policies వంటి లోతైన అంశాల గురించి ఈ page లో వివరంగా లేదు — వాటి కోసం వేరే dedicated blog post ని ఆర్టికల్ reference చేస్తుంది.

## సారాంశం (Summary Table)

| Phase | అర్థం |
|---|---|
| Pending | Schedule అవుతోంది / image download అవుతోంది |
| Running | Pod సక్రమంగా run అవుతోంది |
| Succeeded | అన్ని containers విజయవంతంగా పూర్తయ్యాయి |
| Failed | ఏదో ఒక container failure తో exit అయ్యింది |
| Unknown | Pod status తెలియడం లేదు |
