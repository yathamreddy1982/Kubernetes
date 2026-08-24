# Kubernetes Commands – Correct vs Wrong (Telugu Explanation తో)

`kubernetes_commands.sh` file లో నేను రాసిన commands లో కొన్ని **తప్పు (wrong syntax)** గా ఉన్నాయి, వాటిని ఇక్కడ correct command తో పోల్చి, ఎందుకు తప్పో Telugu లో explain చేసాను. Clean/correct commands మాత్రమే `kub_command.sh` file లో ఉన్నాయి.

---

## 1. Rancher Desktop Control

| Command | Explanation (తెలుగు) |
|---|---|
| `rdctl shutdown` | Rancher Desktop cluster (VM) ని shutdown చేస్తుంది. |
| `rdctl start` | Rancher Desktop cluster ని తిరిగి start చేస్తుంది. |

---

## 2. Port Forwarding

| ❌ Wrong | ✅ Correct | Difference (తెలుగు) |
|---|---|---|
| `kubectl port -forward pod/nginx 8080:80` | `kubectl port-forward pod/nginx 8080:80` | `port` మరియు `forward` మధ్య **space** పెట్టకూడదు — ఇది ఒకే flag/subcommand: **`port-forward`** (hyphen తో, space లేకుండా). Space పెడితే kubectl దీన్ని రెండు వేర్వేరు words గా అర్థం చేసుకుని error ఇస్తుంది. |

`kubectl port-forward` — idi local machine లోని ఒక port (ఇక్కడ 8080) ని, pod లోపలి port (80) కి connect చేస్తుంది, browser లో `localhost:8080` open చేస్తే pod లోని app కనిపిస్తుంది.

---

## 3. Pod వివరాలు చూడటం

| Command | Explanation (తెలుగు) |
|---|---|
| `kubectl get pods -o wide` | Pods list ని Node name, Pod IP తో సహా చూపిస్తుంది. |
| `kubectl top pod --all-namespaces` | అన్ని namespaces లోని pods CPU/Memory usage చూపిస్తుంది. |
| `kubectl describe pod narayana` | ఒక specific pod ("narayana") పూర్తి details + events (debugging కి ఉపయోగపడేవి) చూపిస్తుంది. |

| ❌ Wrong | ✅ Correct | Difference (తెలుగు) |
|---|---|---|
| `ubectl describe pod narayana` | `kubectl describe pod narayana` | `kubectl` అనే word లో **`k` missing** — typo వల్ల "command not found" error వస్తుంది. |
| `kubectl top pod -o wide --all-namespaces` | `kubectl top pod --all-namespaces` | `kubectl top` command **`-o` (output format) flag ని support చేయదు** — ఇది `get` command కోసమే. `-o` పెడితే `unknown shorthand flag` error వస్తుంది. |

---

## 4. Pod Delete చేయడం

| ❌ Wrong | ✅ Correct | Difference (తెలుగు) |
|---|---|---|
| `kubectl delete govinda` | `kubectl delete pod govinda` | Resource **type** (`pod`) ఇవ్వకపోతే, kubectl కి దేన్ని delete చేయాలో తెలియదు — error వస్తుంది. Delete command ki eppudు `<resource-type> <name>` format లో ఇవ్వాలి. |

```
kubectl delete pod narayana
```
Idi "narayana" ane pod ni cluster నుంచి తీసేస్తుంది.

---

## 5. YAML File నుంచి Create / Apply చేయడం

| Command | Explanation (తెలుగు) |
|---|---|
| `kubectl create -f narayana-nginx.yaml` | YAML file నుంచి **కొత్తగా మాత్రమే** resource create చేస్తుంది (Imperative style). Resource already unte → **`AlreadyExists` error** వస్తుంది, malli malli run చేయలేరు. |
| `kubectl apply -f narayana-nginx.yaml` | YAML file లో define చేసిన config prakaram, resource **create (లేదా already unte update)** చేస్తుంది (Declarative style). Malli malli run చేసినా safe (idempotent) — error రాదు. Production లో ఎక్కువగా ఇదే వాడతారు. |
| `kubectl get pods` | ప్రస్తుతం unna pods anni list చేస్తుంది. |

**Practical example:** మొదటిసారి `create -f` run చేస్తే pod create అవుతుంది. అదే command రెండోసారి run చేస్తే error వస్తుంది. కానీ `apply -f` ని ఎన్నిసార్లు run చేసినా (config మార్చినా, మార్చకపోయినా) error రాదు — అందుకే `apply` ని ఎక్కువగా వాడతారు. Full comparison table కోసం ఈ file చివర్లో ఉన్న "create vs apply" section చూడండి (ముందు conversation లో ఇచ్చిన నోట్స్ `kubernetes_notes.sh` file లో కూడా ఉన్నాయి).

**Common pattern:** Pod ని fresh గా recreate చేయాలంటే —
```
kubectl delete pod narayana
kubectl apply -f narayana-nginx.yaml
```
(delete చేసి, malli apply చేస్తే, కొత్త pod fresh state తో వస్తుంది)

---

## 6. `kubectl run` — Image నుంచి Direct గా Pod Create చేయడం

| Command | Explanation (తెలుగు) |
|---|---|
| `kubectl run hello-world --image=hashicorp/http-echo --args="-text=Hello World" --port=5678` | `http-echo` image తో "Hello World" text ని port 5678 లో serve చేసే pod create చేస్తుంది (`--args` flag తో). |
| `kubectl run hello-world-2 --image=hashicorp/http-echo --port=5678 -- -text="Hello World"` | పైదాని లాంటిదే, కానీ `--args` flag కి బదులు `--` (container command separator) తో ఇచ్చినది. **Note:** pod name ని `hello-world-2` గా మార్చాను — ఎందుకంటే మొదటి command ఇప్పటికే `hello-world` పేరుతో pod create చేస్తుంది, అదే పేరుతో మళ్ళీ create చేస్తే `AlreadyExists` error వస్తుంది. |
| `kubectl run hello-exit --image=busybox --restart=Never -- echo "Hello World from an exiting pod"` | busybox image తో `echo` command run చేసి, print చేసిన వెంటనే container exit అవుతుంది. `--restart=Never` వల్ల pod మళ్ళీ restart కాదు. |
| `kubectl run network-check --image=curlimages/curl --restart=Never -- curl -s https://ifconfig.me` | `curl` image తో internet లో మన public IP address ని fetch చేసి చూపిస్తుంది. |

**Note:** Original commands చివర్లో `\n` (literal characters) ఉన్నాయి — avi typo, తీసేయాలి. Terminal లో `\n` అనేది కొత్త line కాదు, అది literal గా `\n` అనే characters గానే command లో కలిసిపోయి, syntax error కి దారితీయవచ్చు.

---

## 7. Pod Config Edit చేయడం

| ❌ Wrong | ✅ Correct | Difference (తెలుగు) |
|---|---|---|
| `kubectl edit pod narayana-nginx.yaml` | `kubectl edit pod narayana` | `kubectl edit pod` కి **pod name** ఇవ్వాలి, `.yaml` **file name** కాదు. Cluster లో `narayana-nginx.yaml` అనే పేరుతో pod ఉండదు కాబట్టి `NotFound` error వస్తుంది. |

**వేరు వేరు commands, వేరు వేరు purpose:**
- `kubectl edit pod narayana` → **cluster లో already running unna pod** ని live గా edit చేస్తుంది (`kubectl` ద్వారా)
- `vi narayana-nginx.yaml` → **host machine మీద local file** ని (apply చేయకముందు) text editor తో edit చేస్తుంది (`kubectl` ప్రమేయం లేదు, ఇది కేవలం file editing)

---

## 8. Real-time Monitoring

| Command | Explanation (తెలుగు) |
|---|---|
| `kubectl get pods --watch` | Pods status ని **live గా** (real-time) watch చేస్తుంది — ఏదైనా change (create/delete/status change) జరిగితే వెంటనే screen మీద కనిపిస్తుంది. ఆపాలంటే `Ctrl+C`. |

---

## Summary — Mistakes Quick Reference

| Mistake Type | Example | Fix |
|---|---|---|
| Missing hyphen | `port -forward` | `port-forward` |
| Missing resource type | `delete govinda` | `delete pod govinda` |
| Typo in command name | `ubectl describe` | `kubectl describe` |
| Unsupported flag | `top pod -o wide` | `top pod` (no `-o`) |
| Wrong argument (file name instead of pod name) | `edit pod file.yaml` | `edit pod <pod-name>` |
| Stray literal characters | `...pod\n` | remove `\n` |
