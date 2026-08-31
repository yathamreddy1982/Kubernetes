# Kubernetes (kubectl) Commands

*తెలుగులో వివరణ — Examples తో | ఉదాహరణ pod పేరు: costco*

---

## 1. kubectl config view / kubectl config view --minify

Kubeconfig file లో ఉన్న configuration (**clusters, users, contexts**) చూపిస్తుంది. `--minify` → ప్రస్తుతం active గా ఉన్న context కి సంబంధించిన details మాత్రమే చూపిస్తుంది.

```bash
kubectl config view
kubectl config view --minify
```

## 2. kubectl config current-context

ఇప్పుడు active గా ఉన్న context పేరు మాత్రమే చూపిస్తుంది — ఏ **cluster + user + namespace** లో పని చేస్తున్నారో తెలుస్తుంది.

```bash
kubectl config current-context
```

## 3. kubectl port-forward pod/costco 8082:80 (లేదా) kubectl port-forward costco 8082:80

Local port 8082 ని pod లో ఉన్న port 80 కి forward చేస్తుంది. `localhost:8082` లో access చేయవచ్చు. రెండు commands ఒక్కటే — `pod/` prefix optional.

```bash
kubectl port-forward pod/costco 8082:80
kubectl port-forward costco 8082:80
```

## 4. kubectl get pods -o wide

Pods list చేస్తుంది, కానీ **extra columns** తో — Node పేరు, Pod IP లాంటివి. Debugging కి ఉపయోగం (ఏ pod ఏ node లో ఉందో తెలుస్తుంది).

```bash
kubectl get pods -o wide
```

## 5. kubectl get pods -o yaml --all-namespaces

అన్ని namespaces లో ఉన్న pods ని **full YAML** format లో చూపిస్తుంది (complete config అంతా). *Note:* `--all-namespaces` కి short form `-A` కూడా వాడవచ్చు.

```bash
kubectl get pods -o yaml --all-namespaces
```

## 6. kubectl get pods

Current namespace లో ఉన్న pods అన్నీ simple గా list చేస్తుంది (**Name, Ready, Status, Restarts, Age**).

```bash
kubectl get pods
```

## 7. kubectl get pods --all-namespaces

Cluster లో **అన్ని namespaces** లో ఉన్న pods ని list చేస్తుంది.

```bash
kubectl get pods --all-namespaces
kubectl get pods -A   # short form
```

## 8. kubectl edit pod &lt;pod-name&gt;

Pod YAML ని editor లో open చేసి, **live గా మార్చడానికి**. Save చేస్తే changes వెంటనే apply అవుతాయి.

```bash
kubectl edit pod costco
```

## 9. kubectl delete pod &lt;pod-name&gt;

చెప్పిన pod ని **delete** చేస్తుంది.

```bash
kubectl delete pod costco
```

## 10. kubectl get pods --watch

Pods status ని **real-time గా** చూస్తుంది. Status మారితే (Pending → Running లాంటివి) screen లో వెంటనే update అవుతుంది. ఆపాలంటే `Ctrl+C`.

```bash
kubectl get pods --watch
kubectl get pods -w   # short form
```

## 11. kubectl exec -it &lt;pod-name&gt; -- /bin/bash

Running pod లో ఉన్న **container లోపలికి వెళ్ళి**, దాంట్లో command run చేయడానికి. Basically pod లోపల terminal (shell) open అవుతుంది.

```bash
kubectl exec -it costco -- /bin/bash
```

**Flags అర్థం:**

- `-i` (interactive) → మీ input ని container కి పంపిస్తుంది (keyboard connect అవుతుంది)
- `-t` (TTY) → terminal session ఇస్తుంది (సరైన shell prompt కోసం)
- `--` → దీని తర్వాత వచ్చేది container లో run అవ్వాలి అని చెప్తుంది
- `/bin/bash` → bash shell open చేస్తుంది

లోపల normal Linux commands run చేయవచ్చు; బయటకి రావాలంటే `exit`.

```bash
kubectl exec -it costco -- /bin/sh              # bash లేకపోతే sh వాడాలి
kubectl exec -it costco -c nginx -- /bin/bash   # multiple containers ఉంటే -c తో
kubectl exec costco -- ls /usr/share/nginx/html # ఒకే command (shell అవసరం లేదు)
```

---

# ఇంకా కొన్ని ముఖ్యమైన Basic Commands

## 12. kubectl logs &lt;pod-name&gt; ⭐ చాలా important

Pod లో container యొక్క **logs** చూపిస్తుంది. Debugging కి describe తర్వాత ఎక్కువ use అయ్యేది ఇదే.

```bash
kubectl logs costco
kubectl logs costco -f          # -f = live logs (follow), real-time
kubectl logs costco --previous  # crash అయిన పూర్వపు container logs
```

## 13. kubectl describe pod &lt;pod-name&gt; ⭐

Pod గురించి full details + **Events** చూపిస్తుంది (errors, scheduling issues). Debugging కి #1 command.

```bash
kubectl describe pod costco
```

## 14. kubectl apply -f &lt;file&gt; / kubectl create -f &lt;file&gt; ⭐

YAML file నుంచి resource create/update చేయడానికి. `apply` → లేకపోతే create, ఉంటే update (safe). `create` → కొత్తగా create, ఉంటే error.

```bash
kubectl apply -f pod.yaml     # create లేదా update (recommended)
kubectl create -f pod.yaml    # కొత్తగా create మాత్రమే
```

## 15. kubectl run &lt;name&gt; --image=&lt;image&gt;

YAML file అవసరం లేకుండా, ఒకే line లో pod create చేయడానికి.

```bash
kubectl run costco --image=httpd
```

## 16. kubectl get — వేరే resources

మనం `get pods` మాత్రమే చూసాము, కానీ వేరే resources కూడా చూడవచ్చు:

```bash
kubectl get nodes         # cluster లో machines
kubectl get deployments   # deployments
kubectl get services      # or  kubectl get svc
kubectl get namespaces    # or  kubectl get ns
kubectl get all           # అన్ని resources ఒకేసారి
```

## 17. kubectl describe node &lt;node-name&gt;

Node గురించి details — capacity, resources, ఏ pods run అవుతున్నాయో.

```bash
kubectl describe node <node-name>
```

## 18. Rollout commands (deployments కి)

Deployment update, restart, rollback చేయడానికి:

```bash
kubectl rollout status deployment/<name>    # update status
kubectl rollout restart deployment/<name>   # pods restart
kubectl rollout undo deployment/<name>      # పూర్వపు version కి rollback
```

## 19. kubectl scale

Deployment లో ఎన్ని pods కావాలో మార్చడానికి (replicas).

```bash
kubectl scale deployment/<name> --replicas=3
```

## 20. ఉపయోగపడే చిన్న commands

```bash
kubectl version           # kubectl & cluster version
kubectl cluster-info      # cluster info
kubectl explain pod       # resource fields explanation (documentation)
kubectl api-resources     # అన్ని resource types list
```

---

# Deployment & ReplicaSet Commands

ఇప్పటివరకు మనం **Pods** చూసాము. కానీ real-world లో single pod కాకుండా **Deployment** వాడతాము — ఎందుకంటే అది ఎన్ని pods (replicas) కావాలో manage చేస్తుంది, ఒక pod చచ్చిపోతే వెంటనే కొత్తది create చేస్తుంది. Deployment వెనుక automatic గా **ReplicaSet** ఉంటుంది — అదే pods count maintain చేస్తుంది.

## 21. kubectl create deployment — replicas తో

ఒక deployment create చేసి, అందులో ఎన్ని pods (replicas) కావాలో చెప్పడానికి.

```bash
kubectl create deployment peoplebank --image=httpd --replicas=4
```

**Command breakdown:**

- `create deployment` → deployment రకం resource create చేయి
- `peoplebank` → deployment పేరు
- `--image=httpd` → ఏ container image వాడాలి
- `--replicas=4` → 4 pods run చేయి

⚠️ **Note:** కొన్ని పాత kubectl versions లో `create deployment` తో `--replicas` support కాదు. అప్పుడు ముందు deployment create చేసి, తర్వాత scale చేయండి:

```bash
kubectl create deployment peoplebank --image=httpd
kubectl scale deployment peoplebank --replicas=4
```

Verify చేయడానికి:

```bash
kubectl get deployment peoplebank    # deployment status
kubectl get pods                     # 4 pods run అవుతున్నాయా
```

## 22. --dry-run తో YAML file create చేయడం ⭐

Command run చేయకుండా, దాని **YAML file** generate చేయడానికి `--dry-run=client -o yaml` వాడతాము. ఇది చాలా useful — YAML మొత్తం చేతితో రాయాల్సిన అవసరం లేదు.

```bash
kubectl create deployment peoplebank --image=httpd --replicas=4 \
  --dry-run=client -o yaml > pbank.yaml
```

**Command breakdown:**

- `--dry-run=client` → నిజంగా create చేయవద్దు, కేవలం preview చూపించు
- `-o yaml` → output ని YAML format లో ఇవ్వు
- `> pbank.yaml` → ఆ YAML ని pbank.yaml file లో save చేయి

Example (nginx తో, 3 replicas):

```bash
kubectl create deployment ven-dep --image=nginx --replicas=3 \
  --dry-run=client -o yaml > 3nginx.yaml
```

ఇప్పుడు `3nginx.yaml` file open చేసి, కావాల్సిన మార్పులు చేసి, `kubectl apply` తో deploy చేయవచ్చు.

## 23. kubectl apply -f — YAML నుంచి deploy

Generate చేసిన (లేదా రాసిన) YAML file నుంచి resource create/update చేయడానికి.

```bash
kubectl apply -f 3nginx.yaml    # nginx deployment deploy
kubectl apply -f pbank.yaml     # peoplebank deployment deploy
```

💡 `apply` idempotent — మళ్ళీ run చేస్తే error రాదు. లేకపోతే create, ఉంటే update చేస్తుంది. YAML files తో ఎప్పుడూ `apply` వాడటం best practice.

⚠️ **Warning వస్తే:** "missing last-applied-configuration annotation" అనే warning వస్తే — ఆ resource ని ముందు `create` తో చేసారని అర్థం. కానీ kubectl automatic గా fix చేసి apply చేస్తుంది, so problem లేదు. తర్వాత నుంచి warning రాదు.

## 24. kubectl get rs — ReplicaSets చూడటం

Deployment create చేస్తే, దాని వెనుక ఒక **ReplicaSet** automatic గా వస్తుంది. దాన్ని చూడటానికి:

```bash
kubectl get rs                # ReplicaSets list (short form)
kubectl get replicasets       # full form (same thing)
```

Output ఇలా ఉంటుంది:

```
NAME                   DESIRED   CURRENT   READY   AGE
ven-dep-5cf794cb4c     3         3         3       10m
```

ఇక్కడ ReplicaSet పేరు = deployment పేరు + random hash. ఉదా: `ven-dep-5cf794cb4c` (ven-dep deployment యొక్క ReplicaSet).

## 25. kubectl describe replicasets.apps ⭐

ReplicaSet యొక్క full details + Events చూడటానికి. Deployment సరిగ్గా pods create చేయట్లేదా, ఎందుకో debug చేయడానికి ఉపయోగం.

```bash
kubectl describe replicasets.apps                       # అన్ని ReplicaSets
kubectl describe replicasets.apps ven-dep-5cf794cb4c    # specific ఒకటి
kubectl describe rs ven-dep-5cf794cb4c                  # short form (same)
```

⚠️ **Spelling జాగ్రత్త:** `replcasets` లేదా `replcatesets` కాదు — సరైనది `replicasets` (r-e-p-l-i-c-a-s-e-t-s).

💡 `ven-dep` (deployment పేరు మాత్రమే) ఇస్తే error రావచ్చు — ReplicaSet కి full పేరు (`ven-dep-5cf794cb4c`) కావాలి. ముందు `kubectl get rs` run చేసి, exact పేరు copy చేసుకోండి.

**describe output లో ఏమి కనిపిస్తుంది:**

- Selector — ఏ labels తో pods match చేస్తోందో
- Replicas — `3 current / 3 desired` (ఎన్ని ఉన్నాయి / ఎన్ని కావాలి)
- Pod Template — కొత్త pods ఏ image, config తో create చేస్తుందో
- Events — pod creation, scaling events (debugging కి)

## 26. Pod delete చేస్తే ReplicaSet ఏం చేస్తుంది?

ReplicaSet manage చేసే ఒక pod ని delete చేస్తే, ReplicaSet **వెంటనే కొత్త pod create చేస్తుంది** — ఎందుకంటే desired count (ఉదా: 3) maintain చేయాలి. ఇదే ReplicaSet యొక్క పని (self-healing).

```bash
kubectl delete pod ven-dep-5cf794cb4c-5b56z   # ఒక pod delete
kubectl get pods                              # కొత్త pod వచ్చిందా చూడండి
```

Delete చేసిన వెంటనే `get pods` చూస్తే — పాత pod పోయి, కొత్త pod (వేరే hash తో) వచ్చి ఉంటుంది. Count ఎప్పుడూ 3 గానే ఉంటుంది.

## 27. kubectl create deployment --help

ఏదైనా command గురించి అన్ని options, examples చూడటానికి `--help` వాడండి. `| less` జోడిస్తే, output ని page-by-page scroll చేయవచ్చు (q నొక్కితే బయటకి).

```bash
kubectl create deployment --help | less
# scroll: ↑ ↓ arrows | బయటకి రావడానికి: q
```

ఏ command కి అయినా `--help` పని చేస్తుంది — ఉదా: `kubectl apply --help`, `kubectl get --help`.

---

## Summary Table

| Command | పని (What it does) |
| --- | --- |
| `config view --minify` | Current config చూపిస్తుంది |
| `config current-context` | Active context పేరు |
| `port-forward costco 8082:80` | Local port → pod port |
| `get pods -o wide` | Node, IP తో extra details |
| `get pods -o yaml -A` | Full YAML, అన్ని namespaces |
| `get pods` | Simple list |
| `get pods --all-namespaces` | అన్ని namespaces list |
| `edit pod <name>` | Live edit |
| `delete pod <name>` | Pod delete |
| `get pods --watch` | Real-time monitoring |
| `exec -it <name> -- /bin/bash` | Container లోపలికి వెళ్ళడం |
| `logs <name>` ⭐ | Container logs (debugging) |
| `describe pod <name>` ⭐ | Details + Events (errors) |
| `apply -f <file>` ⭐ | YAML నుంచి create/update |
| `create -f <file>` | YAML నుంచి create మాత్రమే |
| `run <name> --image=<img>` | Quick pod (file లేకుండా) |
| `get nodes / svc / deploy` | వేరే resources చూడటం |
| `get all` | అన్ని resources ఒకేసారి |
| `describe node <name>` | Node details |
| `rollout status/restart/undo` | Deployment manage |
| `scale --replicas=3` | Pods count మార్చడం |
| `version / cluster-info` | Cluster & version info |
| `explain / api-resources` | Documentation, resource types |
| `create deployment <name> --image=<img> --replicas=4` | Deployment + 4 pods create |
| `... --dry-run=client -o yaml > file.yaml` | Command నుంచి YAML file generate |
| `apply -f <file>.yaml` | YAML నుంచి deploy (create/update) |
| `get rs` | ReplicaSets list |
| `describe replicasets.apps <name>` | ReplicaSet details + Events |
| `scale deployment <name> --replicas=4` | Replicas count మార్చడం |
| `delete pod <rs-pod-name>` | Pod delete (RS కొత్తది create చేస్తుంది) |
| `create deployment --help \| less` | Command options & examples |

---

*గమనిక: పైన ఉన్న ఉదాహరణలలో **costco** అనేది pod పేరు — మీ pod పేరు తో మార్చుకోండి.*
