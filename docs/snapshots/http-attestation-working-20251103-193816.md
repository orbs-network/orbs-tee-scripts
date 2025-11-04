# http-attestation-working Setup Documentation

**Generated**: Mon Nov  3 19:38:16 UTC 2025
**User**: ubuntu
**Instance**: 

---

## System State

### OS Information
```
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
```

### Kernel
```
Linux ip-172-31-57-189 6.14.0-1015-aws #15~24.04.1-Ubuntu SMP Tue Sep 23 22:44:48 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
```

### Available Memory
```
               total        used        free      shared  buff/cache   available
Mem:            15Gi       2.4Gi       1.7Gi       2.7Mi        11Gi        13Gi
Swap:             0B          0B          0B
```

### Disk Usage
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        61G   16G   46G  26% /
```

---

## Installed Software

### docker
```
Docker version 28.2.2, build 28.2.2-0ubuntu1~24.04.1
```

### cargo
```
cargo 1.91.0 (ea2d97820 2025-10-10)
```

### node
```
v20.19.5
```

### npm
```
10.8.2
```

### python3
```
Python 3.12.3
```

### git
```
git version 2.43.0
```


---

## Running Services

```
  UNIT                                           LOAD   ACTIVE SUB     DESCRIPTION
  acpid.service                                  loaded active running ACPI event daemon
  chrony.service                                 loaded active running chrony, an NTP client/server
  containerd.service                             loaded active running containerd container runtime
  cron.service                                   loaded active running Regular background program processing daemon
  dbus.service                                   loaded active running D-Bus System Message Bus
  docker.service                                 loaded active running Docker Application Container Engine
  getty@tty1.service                             loaded active running Getty on tty1
  irqbalance.service                             loaded active running irqbalance daemon
  ModemManager.service                           loaded active running Modem Manager
  multipathd.service                             loaded active running Device-Mapper Multipath Device Controller
  networkd-dispatcher.service                    loaded active running Dispatcher daemon for systemd-networkd
  orbs-tee-enclave.service                       loaded active running ORBS TEE Price Oracle Enclave
  orbs-tee-host.service                          loaded active running ORBS TEE Host API Server
  polkit.service                                 loaded active running Authorization Manager
  rsyslog.service                                loaded active running System Logging Service
  serial-getty@ttyS0.service                     loaded active running Serial Getty on ttyS0
  snap.amazon-ssm-agent.amazon-ssm-agent.service loaded active running Service for snap application amazon-ssm-agent.amazon-ssm-agent
  snapd.service                                  loaded active running Snap Daemon
  ssh.service                                    loaded active running OpenBSD Secure Shell server
```

---

## Network Configuration

### Listening Ports
```
Netid State  Recv-Q Send-Q      Local Address:Port  Peer Address:PortProcess
udp   UNCONN 0      0              127.0.0.54:53         0.0.0.0:*          
udp   UNCONN 0      0           127.0.0.53%lo:53         0.0.0.0:*          
udp   UNCONN 0      0      172.31.57.189%ens5:68         0.0.0.0:*          
udp   UNCONN 0      0               127.0.0.1:323        0.0.0.0:*          
udp   UNCONN 0      0                   [::1]:323           [::]:*          
tcp   LISTEN 0      4096            127.0.0.1:37271      0.0.0.0:*          
tcp   LISTEN 0      4096           127.0.0.54:53         0.0.0.0:*          
tcp   LISTEN 0      4096        127.0.0.53%lo:53         0.0.0.0:*          
tcp   LISTEN 0      4096              0.0.0.0:22         0.0.0.0:*          
tcp   LISTEN 0      4096                 [::]:22            [::]:*          
```

### Firewall Status
```
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy DROP)
target     prot opt source               destination         
DOCKER-USER  0    --  0.0.0.0/0            0.0.0.0/0           
DOCKER-FORWARD  0    --  0.0.0.0/0            0.0.0.0/0           

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

Chain DOCKER (1 references)
target     prot opt source               destination         
DROP       0    --  0.0.0.0/0            0.0.0.0/0           

Chain DOCKER-BRIDGE (1 references)
target     prot opt source               destination         
DOCKER     0    --  0.0.0.0/0            0.0.0.0/0           

Chain DOCKER-CT (1 references)
```

---

## Recent File Changes (Last Hour)

### Modified Files
```
/home/ubuntu/orbs-tee-host/package-lock.json
/home/ubuntu/orbs-tee-host/dist/l3/client.js.map
/home/ubuntu/orbs-tee-host/dist/l3/client.d.ts.map
/home/ubuntu/orbs-tee-host/dist/l3/client.d.ts
/home/ubuntu/orbs-tee-host/dist/l3/client.js
/home/ubuntu/orbs-tee-host/dist/index.js.map
/home/ubuntu/orbs-tee-host/dist/api/middleware/error.d.ts.map
/home/ubuntu/orbs-tee-host/dist/api/middleware/logging.js.map
/home/ubuntu/orbs-tee-host/dist/api/middleware/logging.d.ts
/home/ubuntu/orbs-tee-host/dist/api/middleware/auth.d.ts
/home/ubuntu/orbs-tee-host/dist/api/middleware/error.d.ts
/home/ubuntu/orbs-tee-host/dist/api/middleware/auth.js.map
/home/ubuntu/orbs-tee-host/dist/api/middleware/auth.d.ts.map
/home/ubuntu/orbs-tee-host/dist/api/middleware/auth.js
/home/ubuntu/orbs-tee-host/dist/api/middleware/error.js.map
/home/ubuntu/orbs-tee-host/dist/api/middleware/logging.d.ts.map
/home/ubuntu/orbs-tee-host/dist/api/middleware/error.js
/home/ubuntu/orbs-tee-host/dist/api/middleware/logging.js
/home/ubuntu/orbs-tee-host/dist/api/server.d.ts
/home/ubuntu/orbs-tee-host/dist/api/server.d.ts.map
/home/ubuntu/orbs-tee-host/dist/api/server.js.map
/home/ubuntu/orbs-tee-host/dist/api/server.js
/home/ubuntu/orbs-tee-host/dist/api/routes/status.js.map
/home/ubuntu/orbs-tee-host/dist/api/routes/attest.d.ts
/home/ubuntu/orbs-tee-host/dist/api/routes/health.d.ts.map
/home/ubuntu/orbs-tee-host/dist/api/routes/request.js.map
/home/ubuntu/orbs-tee-host/dist/api/routes/status.d.ts
/home/ubuntu/orbs-tee-host/dist/api/routes/status.d.ts.map
/home/ubuntu/orbs-tee-host/dist/api/routes/health.js.map
/home/ubuntu/orbs-tee-host/dist/api/routes/health.d.ts
```

### New Directories
```
/home/ubuntu
/home/ubuntu/orbs-tee-host
/home/ubuntu/orbs-tee-host/node_modules
/home/ubuntu/.npm/_logs
/home/ubuntu/.nitro_cli
/home/ubuntu/orbs-tee-enclave-nitro
/home/ubuntu/orbs-tee-enclave-nitro/src
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/thiserror-0ff65d21d308b34d
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/thiserror-0ff65d21d308b34d/out
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/native-tls-a98fbb9372a80c30
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/native-tls-a98fbb9372a80c30/out
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-8cfaa3dc043201bb
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-8cfaa3dc043201bb/out
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/memoffset-ac733f209bafdeb0
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/memoffset-ac733f209bafdeb0/out
/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/target/release/build/openssl-sys-448452cf93b914e6
```

---

## Key Files

### /home/ubuntu/orbs-tee-host/config.json
- **Size**: 453
- **Modified**: 2025-11-03 19:29:37.843507531 +0000

### /etc/nitro_enclaves/allocator.yaml
- **Size**: 154
- **Modified**: 2025-11-03 18:58:28.374154953 +0000

### /home/ubuntu/price-oracle-v2.eif
- **Size**: 154M
- **Modified**: 2025-11-03 19:17:28.685318410 +0000

### /home/ubuntu/price-oracle.eif
- **Size**: 154M
- **Modified**: 2025-11-03 18:57:23.499692199 +0000

### /home/ubuntu/attestation_document.bin
- **Size**: 4.5K
- **Modified**: 2025-11-03 19:19:46.861153040 +0000


---

## Memory Configuration

### Hugepages
```
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
FileHugePages:         0 kB
HugePages_Total:     640
HugePages_Free:      128
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
Hugetlb:         1310720 kB
```

---

## Recent Logs

### System Logs (Last 20 lines)
```
Nov 03 19:37:25 ip-172-31-57-189 orbs-tee-host[49328]: {"host":"0.0.0.0","level":"info","message":"HTTP server listening","port":8080,"timestamp":"2025-11-03T19:37:25.057Z"}
Nov 03 19:37:27 ip-172-31-57-189 orbs-tee-host[49328]: {"ip":"127.0.0.1","level":"info","message":"Incoming request","method":"POST","path":"/api/v1/request","timestamp":"2025-11-03T19:37:27.849Z"}
Nov 03 19:37:27 ip-172-31-57-189 orbs-tee-host[49328]: {"level":"info","message":"Forwarding request to enclave","method":"get_attestation","timestamp":"2025-11-03T19:37:27.849Z"}
Nov 03 19:37:27 ip-172-31-57-189 orbs-tee-host[49328]: {"duration":17,"level":"info","message":"Request completed","method":"POST","path":"/api/v1/request","status":200,"timestamp":"2025-11-03T19:37:27.865Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49328]: {"ip":"127.0.0.1","level":"info","message":"Incoming request","method":"GET","path":"/api/v1/health","timestamp":"2025-11-03T19:37:54.105Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49328]: {"endpoint":"https://guardian1.orbs.network","error":"getaddrinfo ENOTFOUND guardian1.orbs.network","level":"warn","message":"L3 endpoint is unreachable","timestamp":"2025-11-03T19:37:54.196Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49328]: {"duration":92,"level":"info","message":"Request completed","method":"GET","path":"/api/v1/health","status":200,"timestamp":"2025-11-03T19:37:54.197Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49328]: {"ip":"127.0.0.1","level":"info","message":"Incoming request","method":"GET","path":"/api/v1/status","timestamp":"2025-11-03T19:37:54.374Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49328]: {"endpoint":"https://guardian1.orbs.network","error":"getaddrinfo ENOTFOUND guardian1.orbs.network","level":"warn","message":"L3 endpoint is unreachable","timestamp":"2025-11-03T19:37:54.381Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49328]: {"duration":8,"level":"info","message":"Request completed","method":"GET","path":"/api/v1/status","status":200,"timestamp":"2025-11-03T19:37:54.382Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49328]: {"ip":"127.0.0.1","level":"info","message":"Incoming request","method":"POST","path":"/api/v1/request","timestamp":"2025-11-03T19:37:54.588Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49328]: {"level":"info","message":"Forwarding request to enclave","method":"get_price","timestamp":"2025-11-03T19:37:54.588Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49328]: {"error":"Write failed: write EPIPE","level":"error","message":"Request handling failed","timestamp":"2025-11-03T19:37:54.590Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49328]: {"level":"error","message":"Unhandled Rejection","promise":{},"reason":{"name":"VsocketError"},"timestamp":"2025-11-03T19:37:54.591Z"}
Nov 03 19:37:54 ip-172-31-57-189 orbs-tee-host[49314]: [nodemon] app crashed - waiting for file changes before starting...
Nov 03 19:38:17 ip-172-31-57-189 sudo[49576]:   ubuntu : PWD=/home/ubuntu/orbs-tee-host ; USER=root ; COMMAND=/usr/sbin/iptables -L -n
Nov 03 19:38:17 ip-172-31-57-189 sudo[49576]: pam_unix(sudo:session): session opened for user root(uid=0) by ubuntu(uid=1000)
Nov 03 19:38:17 ip-172-31-57-189 sudo[49576]: pam_unix(sudo:session): session closed for user root
Nov 03 19:38:17 ip-172-31-57-189 sudo[49608]:   ubuntu : PWD=/home/ubuntu/orbs-tee-host ; USER=root ; COMMAND=/usr/bin/journalctl -n 20
Nov 03 19:38:17 ip-172-31-57-189 sudo[49608]: pam_unix(sudo:session): session opened for user root(uid=0) by ubuntu(uid=1000)
```

---

## Environment Variables (Filtered)

```
HOME=/home/ubuntu
PATH=/home/ubuntu/.local/bin:/home/ubuntu/.cargo/bin:/home/ubuntu/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
USER=ubuntu
```

---

## Quick Commands Reference

```bash
# Check enclave status
source /tmp/nitro-cli/build/install/etc/profile.d/nitro-cli-env.sh
nitro-cli describe-enclaves

# View logs
sudo journalctl -u nitro-enclaves-allocator -f

# Test enclave
python3 /home/ubuntu/test-enclave-full.py

# Verify setup
/home/ubuntu/verify-enclave.sh
```

---

**Documentation generated automatically by auto-document-setup.sh**
**Saved to**: /home/ubuntu/http-attestation-working-20251103-193816.md
