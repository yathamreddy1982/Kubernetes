#!/bin/bash
# Kubernetes / Rancher Desktop practice commands - explanations Telugu (Tenglish) lo

# ---------------------------------------------------
# 1) Rancher Desktop control cheyadaniki (cluster start/stop)
# ---------------------------------------------------

# Rancher Desktop cluster ni shutdown cheyadam (VM/cluster aagipotundi)
rdctl shutdown

# Rancher Desktop cluster ni malli start cheyadam
rdctl start


# ---------------------------------------------------
# 2) Port-forward - local machine నుంచి pod ki direct ga connect avvadaniki
# ---------------------------------------------------

# localhost:8080 ni nginx pod lopala port 80 ki forward chestundi
# (hyphen tho "port-forward" ani undali, space pettakudadu)
kubectl port-forward pod/nginx 8080:80


# ---------------------------------------------------
# 3) Pods vivarālu (details) chudataniki
# ---------------------------------------------------

# Anni pods, vati Node/IP tho సహా చూపిస్తుంది (wide format)
kubectl get pods -o wide

# Anni namespaces lo unna pods CPU/Memory usage chupistundi
kubectl top pod --all-namespaces

# Oka specific pod ("narayana") full details (events, status, config) chupistundi
kubectl describe pod narayana


# ---------------------------------------------------
# 4) Pods delete cheyadam
# ---------------------------------------------------

# "pod" type + name specify cheyali (type ivvakapothe kubectl deniki delete cheyalo teliyadu)
kubectl delete pod govinda

# "narayana" ane pod ni delete cheyadam
kubectl delete pod narayana


# ---------------------------------------------------
# 5) YAML file నుంచి pod create/update cheyadam
# ---------------------------------------------------

# create -> KOTHAGA resource create chestundi matrame. Already resource unte "AlreadyExists" error vastundi
# (idi IMPERATIVE style - "idi create cheyi" ane direct command, malli malli run cheyalem)
kubectl create -f narayana-nginx.yaml

# apply -> resource ledu ante create, already unte UPDATE chestundi (error radu)
# (idi DECLARATIVE style - "idi ila undali" ane desired state, malli malli run chesina safe/idempotent)
kubectl apply -f narayana-nginx.yaml

# Anni pods current status chudataniki
kubectl get pods

# Pod ni malli delete chesi, malli apply cheyadam (fresh recreate cheyadaniki common pattern)
kubectl delete pod narayana
kubectl apply -f narayana-nginx.yaml


# ---------------------------------------------------
# 6) kubectl run - image nunchi direct ga pod create cheyadam (examples)
# ---------------------------------------------------

# "hello-world" ane pod, http-echo image tho, "Hello World" ane text ni port 5678 lo serve chestundi
kubectl run hello-world --image=hashicorp/http-echo --args="-text=Hello World" --port=5678

# Same pని, --args flag ki bదులu "--" (container command) tho ivvachu
# (pod name marchali - "hello-world" already unnందున same name tho malli create cheste "AlreadyExists" error vastundi)
kubectl run hello-world-2 --image=hashicorp/http-echo --port=5678 -- -text="Hello World"

# busybox image tho, "echo" command run chesi, print chesi, container exit avutundi (--restart=Never = pod re-run avvadu)
kubectl run hello-exit --image=busybox --restart=Never -- echo "Hello World from an exiting pod"

# curl image tho, internet lo mana public IP address ni fetch chesi chupistundi
kubectl run network-check --image=curlimages/curl --restart=Never -- curl -s https://ifconfig.me


# ---------------------------------------------------
# 7) Pod config edit cheyadam
# ---------------------------------------------------

# Cluster lo already unna pod ni live ga edit cheyadaniki (pod name matrame ivvali, .yaml file name kaadu)
kubectl edit pod narayana

# Local YAML file ni (apply cheyakamunde) text editor (vi) tho edit cheyadam - idi host machine meeda file, pod kaadu
vi narayana-nginx.yaml


# ---------------------------------------------------
# 8) kubectl top - resource usage (CPU/Memory)
# ---------------------------------------------------

# "kubectl top" command "-o" (output format) flag ni support cheyadu, -o lekunda run cheyali
kubectl top pod --all-namespaces


# ---------------------------------------------------
# 9) Real-time ga pods status watch cheyadam
# ---------------------------------------------------

# Ee command run chesaka terminal freeze aినట్టు కనిపిస్తుంది, kani adi wait chestundi -
# eppudaite pods lo edaina change (create/delete/status change) jarigithe, adi live ga screen meeda print chestundi.
# Aapadaniki: Ctrl+C నొక్కండి
kubectl get pods --watch
